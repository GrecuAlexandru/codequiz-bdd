import os
from dotenv import load_dotenv
from flask import Flask, jsonify, render_template, request, redirect, url_for, session, flash
from database import MSSQLConnection
from werkzeug.security import generate_password_hash, check_password_hash
import functools

app = Flask(__name__)
app.secret_key = 'secret_key'

load_dotenv()

DB_HOST = 'localhost'
DB_PORT = 1433
DB_NAME = 'master'
DB_USER = os.getenv('DB_USER', 'SA')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')

def get_db():
    conn = MSSQLConnection(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
    conn.openConnection()
    return conn

# Decorator for login required
def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if 'user_id' not in session:
            flash('Please log in to access this page.', 'error')
            return redirect(url_for('login'))
        
        # Verify user still exists in DB and matches session data
        try:
            db = get_db()
            cursor = db.execute_query("SELECT Username, Role FROM Users WHERE ID = ?", (session['user_id'],))
            row = cursor.fetchone()
            
            if not row:
                # User ID not found
                session.clear()
                db.closeConnection()
                flash('Session expired. Please log in again.', 'error')
                return redirect(url_for('login'))
                
            db_username = row[0]
            db_role = row[1]
            
            # Check if session data matches current DB data (handles DB resets where ID is reused)
            if db_username != session.get('username') or db_role != session.get('role'):
                session.clear()
                db.closeConnection()
                flash('Session invalid (data mismatch). Please log in again.', 'error')
                return redirect(url_for('login'))
                
            db.closeConnection()
        except Exception:
            session.clear()
            flash('Session validation failed. Please log in again.', 'error')
            return redirect(url_for('login'))
            
        return view(**kwargs)
    return wrapped_view

# Decorator for admin required
def admin_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if 'role' not in session or session['role'] != 'Admin':
            flash('Access denied. Admins only.', 'error')
            return redirect(url_for('index'))
        return view(**kwargs)
    return wrapped_view

@app.route('/')
def index():
    return render_template('base.html')

@app.route('/register', methods=('GET', 'POST'))
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        confirm_password = request.form['confirm_password']
        
        if password != confirm_password:
            flash('Passwords do not match.', 'error')
            return redirect(url_for('register'))
            
        hashed_password = generate_password_hash(password)
        
        try:
            db = get_db()
            cursor = db.execute_query(
                "EXEC RegisterUser ?, ?, ?", 
                (username, hashed_password, email)
            )

            # Fetchone can return None if query failed or no result
            row = cursor.fetchone()
            if row:
                result = row[0]
                message = row[1]
                
                db.closeConnection()
                
                if result == 1:
                    flash('Registration successful! Please login.', 'success')
                    return redirect(url_for('login'))
                else:
                    flash(message, 'error')
            else:
                db.closeConnection()
                flash("Registration failed: No response from database.", "error")
                
        except Exception as e:
            flash(f"Registration failed: {str(e)}", 'error')
            
    return render_template('register.html')

@app.route('/login', methods=('GET', 'POST'))
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        try:
            db = get_db()
            cursor = db.execute_query("EXEC LoginUser ?", (username,))
            user = cursor.fetchone()
            db.closeConnection()
            
            if user:
                # user: ID, Username, PasswordHash, Role, Email
                stored_hash = user[2]
                if check_password_hash(stored_hash, password):
                    session.clear()
                    session['user_id'] = user[0]
                    session['username'] = user[1]
                    session['role'] = user[3]
                    return redirect(url_for('quizzes'))
            
            flash('Invalid username or password.', 'error')
            
        except Exception as e:
            flash(f"Login error: {str(e)}", 'error')
            
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.', 'success')
    return redirect(url_for('index'))

@app.route('/quizzes')
@login_required
def quizzes():
    quizzes_list = []
    try:
        db = get_db()
        cursor = db.execute_query("EXEC GetQuizzes")
        rows = cursor.fetchall()
        for row in rows:
            quizzes_list.append({
                'id': row[0],
                'title': row[1],
                'description': row[2],
                'question_count': row[3]
            })
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading quizzes: {e}", "error")
        
    return render_template('quizzes.html', username=session.get('username'), quizzes=quizzes_list)


@app.route('/quiz/<int:quiz_id>')
@login_required
def quiz_intro(quiz_id):
    quiz = None
    has_pending = False
    try:
        db = get_db()
        cursor = db.execute_query("SELECT ID, Title, Description FROM Quizzes WHERE ID = ?", (quiz_id,))
        row = cursor.fetchone()
        if row:
            quiz = {'id': row[0], 'title': row[1], 'description': row[2]}
            
        # Check for pending attempt
        cursor = db.execute_query("SELECT TOP 1 1 FROM QuizAttempts WHERE UserID = ? AND QuizID = ? AND CompletedAt IS NULL", (session['user_id'], quiz_id))
        if cursor.fetchone():
            has_pending = True
            
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading quiz: {e}", "error")
        return redirect(url_for('quizzes'))

    if not quiz:
        flash("Quiz not found", "error")
        return redirect(url_for('quizzes'))

    return render_template('quiz_intro.html', quiz=quiz, has_pending=has_pending)

@app.route('/quiz/<int:quiz_id>/start', methods=['POST'])
@login_required
def start_quiz(quiz_id):
    try:
        db = get_db()
        
        # Start or Resume Attempt
        cursor = db.execute_query("EXEC StartQuizAttempt ?, ?", (session['user_id'], quiz_id))
        row = cursor.fetchone()
        attempt_id = row[0]
        
        # Get Questions for this Quiz
        cursor = db.execute_query("EXEC GetQuestionsByQuiz ?", (quiz_id,))
        rows = cursor.fetchall()
        question_ids = [row[0] for row in rows]
        
        if not question_ids:
            db.closeConnection()
            flash("No questions available for this quiz.", "error")
            return redirect(url_for('quizzes'))

        # Determine current progress
        cursor = db.execute_query("SELECT COUNT(*) FROM UserProgress WHERE AttemptID = ?", (attempt_id,))
        progress_row = cursor.fetchone()
        current_index = progress_row[0]
        
        db.closeConnection()

        session['quiz_attempt_id'] = attempt_id
        session['quiz_question_ids'] = question_ids
        session['quiz_current_index'] = current_index
        
        return redirect(url_for('quiz_question'))
    except Exception as e:
        flash(f"Error starting quiz: {e}", "error")
        return redirect(url_for('quizzes'))

@app.route('/quiz/question')
@login_required
def quiz_question():
    q_ids = session.get('quiz_question_ids')
    idx = session.get('quiz_current_index')
    
    if not q_ids or idx is None or idx >= len(q_ids):
        return redirect(url_for('quiz_result'))
        
    current_q_id = q_ids[idx]
    
    question = None
    answers = []
    try:
        db = get_db()

        # Get Question Text
        cursor = db.execute_query("SELECT Text, Difficulty FROM Questions WHERE ID = ?", (current_q_id,))
        q_row = cursor.fetchone()
        question = {'id': current_q_id, 'text': q_row[0], 'difficulty': q_row[1]}
        
        # Get Answers
        cursor = db.execute_query("EXEC GetAnswersByQuestion ?", (current_q_id,))
        a_rows = cursor.fetchall()
        for row in a_rows:
            answers.append({'id': row[0], 'text': row[1]})
            
        db.closeConnection()
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading question: {e}", "error")
        return redirect(url_for('quizzes'))
        
    return render_template('quiz_question.html', 
                           question=question, 
                           answers=answers, 
                           index=idx + 1, 
                           total=len(q_ids))

@app.route('/quiz/answer', methods=['POST'])
@login_required
def submit_answer():
    question_id = request.form.get('question_id')
    answer_id = request.form.get('answer_id')
    
    if not question_id or not answer_id:
        flash("Please select an answer.", "error")
        return redirect(url_for('quiz_question'))
        
    try:
        attempt_id = session.get('quiz_attempt_id')
        if not attempt_id:
            flash("Session expired.", "error")
            return redirect(url_for('quizzes'))

        db = get_db()
        cursor = db.execute_query("EXEC RecordAttempt ?, ?, ?", 
                                  (attempt_id, question_id, answer_id))
        row = cursor.fetchone()
        is_correct = row[0]
        db.closeConnection()
        
        session['quiz_current_index'] = session.get('quiz_current_index', 0) + 1
        return redirect(url_for('quiz_question'))
        
    except Exception as e:
        flash(f"Error submitting answer: {e}", "error")
        return redirect(url_for('quiz_question'))

@app.route('/quiz/result')
@login_required
def quiz_result():
    # Finalize the attempt
    attempt_id = session.get('quiz_attempt_id')
    score = 0
    total = len(session.get('quiz_question_ids', []))
    
    if attempt_id:
        try:
            db = get_db()
            cursor = db.execute_query("EXEC CompleteQuizAttempt ?", (attempt_id,))
            row = cursor.fetchone()
            score = row[0]
            db.closeConnection()
        except Exception as e:
            flash(f"Error finalizing quiz: {e}", "error")

    # Clear quiz session 
    session.pop('quiz_question_ids', None)
    session.pop('quiz_current_index', None)
    session.pop('quiz_attempt_id', None)
    
    return render_template('quiz_result.html', score=score, total=total)

@app.route('/profile')
@login_required
def profile():
    history = []
    pending = []
    try:
        db = get_db()
        
        # History
        cursor = db.execute_query("EXEC GetQuizHistory ?", (session['user_id'],))
        rows = cursor.fetchall()
        for row in rows:
            history.append({
                'id': row[0],
                'topic': row[1],
                'score': row[2],
                'date': row[3].strftime('%Y-%m-%d %H:%M'),
                'total': row[4]
            })
            
        # Pending
        cursor = db.execute_query("EXEC GetPendingQuizzes ?", (session['user_id'],))
        rows = cursor.fetchall()
        for row in rows:
            pending.append({
                'id': row[2],
                'topic': row[1],
                'date': row[3].strftime('%Y-%m-%d %H:%M'),
                'progress': row[4],
                'total': row[5]
            })
            
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading profile: {e}", "error")
        
    return render_template('profile.html', history=history, pending=pending, username=session.get('username'))

@app.route('/history/<int:attempt_id>')
@login_required
def quiz_history(attempt_id):
    details = []
    try:
        db = get_db()
        cursor = db.execute_query("EXEC GetQuizAttemptDetails ?", (attempt_id,))
        rows = cursor.fetchall()
        for row in rows:
            details.append({
                'question': row[0],
                'answer': row[1],
                'is_correct': row[2],
                'difficulty': row[3]
            })
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading history details: {e}", "error")
        return redirect(url_for('profile'))
        
    return render_template('quiz_history.html', details=details)


@app.route('/contribute', methods=('GET', 'POST'))
@login_required
def contribute():
    if request.method == 'POST':
        question_text = request.form['question_text']
        correct_answer = request.form['correct_answer']
        wrong1 = request.form['wrong1']
        wrong2 = request.form['wrong2']
        wrong3 = request.form['wrong3']
        topic_id = request.form['topic_id']
        
        try:
            db = get_db()
            db.execute_query(
                "EXEC AddContribution ?, ?, ?, ?, ?, ?, ?",
                (session['user_id'], question_text, correct_answer, wrong1, wrong2, wrong3, topic_id)
            )
            db.closeConnection()
            flash('Contribution submitted for review!', 'success')
            return redirect(url_for('contribute'))
        except Exception as e:
            flash(f"Error submitting contribution: {e}", 'error')
    
    topics = []
    my_contributions = []
    try:
        db = get_db()
        # Topics
        cursor = db.execute_query("SELECT ID, Name FROM Topics")
        rows = cursor.fetchall()
        for row in rows:
            topics.append({'id': row[0], 'name': row[1]})
            
        # User History
        cursor = db.execute_query("EXEC GetMyContributions ?", (session['user_id'],))
        rows = cursor.fetchall()
        for row in rows:
            my_contributions.append({
                'question_text': row[0],
                'topic': row[1],
                'status': row[2],
                'date': row[3].strftime('%Y-%m-%d %H:%M')
            })
            
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading data: {e}", 'error')
        
    return render_template('contribute.html', topics=topics, my_contributions=my_contributions)

@app.route('/admin')
@admin_required
def admin_dashboard():
    contributions = []
    quizzes = []
    try:
        db = get_db()
        
        # Get pending contributions
        cursor = db.execute_query("EXEC GetPendingContributions")
        rows = cursor.fetchall()
        for row in rows:
            contributions.append({
                'id': row[0],
                'username': row[1],
                'question_text': row[2],
                'correct_answer': row[3],
                'wrong1': row[4],
                'wrong2': row[5],
                'wrong3': row[6],
                'topic': row[7],
                'date': row[8].strftime('%Y-%m-%d %H:%M')
            })
            
        # Get quizzes for dropdown
        cursor = db.execute_query("SELECT ID, Title FROM Quizzes")
        q_rows = cursor.fetchall()
        for row in q_rows:
            quizzes.append({'id': row[0], 'title': row[1]})
            
        db.closeConnection()
    except Exception as e:
        flash(f"Error loading admin dashboard: {e}", 'error')
        
    return render_template('admin_dashboard.html', contributions=contributions, quizzes=quizzes)

@app.route('/admin/approve', methods=['POST'])
@admin_required
def approve_contribution():
    contribution_id = request.form['contribution_id']
    target_quiz_id = request.form['target_quiz_id']
    difficulty = request.form['difficulty']
    
    try:
        db = get_db()
        db.execute_query(
            "EXEC ApproveContribution ?, ?, ?",
            (contribution_id, target_quiz_id, difficulty)
        )
        db.closeConnection()
        flash('Contribution approved!', 'success')
    except Exception as e:
        flash(f"Error approving contribution: {e}", 'error')
        
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/reject', methods=['POST'])
@admin_required
def reject_contribution():
    contribution_id = request.form['contribution_id']
    
    try:
        db = get_db()
        db.execute_query("EXEC RejectContribution ?", (contribution_id,))
        db.closeConnection()
        flash('Contribution rejected.', 'success')
    except Exception as e:
        flash(f"Error rejecting contribution: {e}", 'error')
        
    return redirect(url_for('admin_dashboard'))

if __name__ == '__main__':
    app.run(debug=True)
