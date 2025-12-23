import random
from database import MSSQLConnection
from werkzeug.security import generate_password_hash
import os
from dotenv import load_dotenv

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

def populate_users_sql(db):
    print("Populating users via SQL script...")
    try:
        with open('populate_users.sql', 'r') as f:
            sql_script = f.read()
            db.execute_query(sql_script)
            # db.conn.commit() - Autocommit is on
    except Exception as e:
        print(f"Error running SQL script: {e}")
        
    # valid users return
    cursor = db.execute_query("EXEC GetTestUsers")
    return [r[0] for r in cursor.fetchall()]

def populate_attempts(db, user_ids, quizzes, attempts_per_user=3):
    print("Simulating quiz attempts...")
    for user_id in user_ids:
        # User takes random quizzes
        selected_quizzes = random.sample(quizzes, k=min(len(quizzes), attempts_per_user))
        
        for quiz in selected_quizzes:
            quiz_id = quiz['id']
            
            # Start Attempt
            cursor = db.execute_query("EXEC StartQuizAttempt ?, ?", (user_id, quiz_id))
            attempt_id = cursor.fetchone()[0]
            
            # Get Questions
            cursor = db.execute_query("EXEC GetQuestionsByQuiz ?", (quiz_id,))
            questions = [{'id': row[0]} for row in cursor.fetchall()]
            
            # Answer Questions
            for q in questions:
                # Get Answers for this question
                cursor = db.execute_query("EXEC GetAnswersWithCorrectness ?", (q['id'],))
                answers = cursor.fetchall()
                
                if not answers:
                    continue
                    
                # Decide if user answers correctly (70% chance)
                is_correct_choice = random.random() < 0.7
                
                valid_answers = [a for a in answers if a[1] == is_correct_choice]
                if not valid_answers:
                    # If we wanted correct but none exist (or vice versa), just pick any
                    selected_answer = random.choice(answers)
                else:
                    selected_answer = random.choice(valid_answers)
                
                db.execute_query("EXEC RecordAttempt ?, ?, ?", (attempt_id, q['id'], selected_answer[0]))
            
            # Complete Quiz
            db.execute_query("EXEC CompleteQuizAttempt ?", (attempt_id,))

def populate_reviews(db, user_ids, quizzes):
    print("Adding reviews...")
    for user_id in user_ids:
        # 50% chance a user leaves reviews
        if random.random() < 0.5:
            continue
            
        # Review random questions from random quizzes
        quiz = random.choice(quizzes)
        cursor = db.execute_query("EXEC GetQuestionIDsByQuiz ?", (quiz['id'],))
        q_ids = [r[0] for r in cursor.fetchall()]
        
        for q_id in q_ids:
            if random.random() < 0.3: # Review 30% of questions
                rating = random.randint(1, 5)
                comment = random.choice(["Great question!", "Too hard.", "Confusing.", "Excellent!", "Needs more time."])
                
                # Use stored proc
                db.execute_query("EXEC AddReview ?, ?, ?, ?", (user_id, q_id, rating, comment))

def populate_contributions(db, user_ids, topics):
    print("Adding contributions...")
    for user_id in user_ids:
        if random.random() < 0.4:
            continue
            
        # Add 1-3 contributions
        count = random.randint(1, 3)
        for _ in range(count):
            topic = random.choice(topics)
            q_text = f"Random Question {random.randint(1000, 9999)} about {topic['name']}"
            
            db.execute_query(
                "EXEC AddContribution ?, ?, 'Correct', 'Wrong1', 'Wrong2', 'Wrong3', ?",
                (user_id, q_text, topic['id'])
            )

def main():
    try:
        db = get_db()
        print("Connected.")
        
        # 1. Get Quizzes and Topics
        cursor = db.execute_query("EXEC GetAllQuizIDs")
        quizzes = [{'id': r[0]} for r in cursor.fetchall()]
        
        cursor = db.execute_query("EXEC GetAllTopics")
        topics = [{'id': r[0], 'name': r[1]} for r in cursor.fetchall()]
        
        # 2. Populate Users
        # We now use the SQL script
        all_users = populate_users_sql(db)
        
        print(f"Total existing test users: {len(all_users)}")
            
        # 3. Simulate Activity
        populate_attempts(db, all_users, quizzes, attempts_per_user=5)
        populate_reviews(db, all_users, quizzes)
        populate_contributions(db, all_users, topics)
        
        db.closeConnection()
        print("Done!")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
