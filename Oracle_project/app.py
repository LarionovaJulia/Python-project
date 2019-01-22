from flask import Flask, render_template, request, redirect, url_for, session, flash
import datetime
import cx_Oracle

user_login = 'larionova'
password = '1342'
server = 'orcl'

db = cx_Oracle.connect(user_login, password, server)
cursor = db.cursor()
#import pdb; pdb.set_trace()


app = Flask(__name__)
app.secret_key = 'plzdonthackme'

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/signup', methods=['POST'])
def signup():
    email = request.form['email']
    sql = f"SELECT user_id from users where email='{email}'"
    cursor.execute(sql)
    email_exists = cursor.fetchall()

    if email_exists:
        flash('Email already exists')
        return redirect(url_for('index'))

    email = request.form['email']
    val = (email, request.form['password'])
    # import pdb; pdb.set_trace()
    test = cursor.callfunc('user_auth.registration', cx_Oracle.STRING, val)
    flash(test)
    db.commit()

    session['email'] = email
    return render_template('signup.html')


@app.route('/login', methods=['POST'])
def login():
    email = request.form['email']
    u_password = request.form['password']

    sql = "select * from table(user_auth.log_in(:email, :password))"
    cursor.execute(sql, email = email, password = u_password)
    users = cursor.fetchall()

    print(users)
    if users:
        user_email = users[0][0]
        session['email'] = user_email
        flash('Login successfull')
        return redirect(url_for('show_lists'))
    else:
        flash('Login failed')
        return redirect(url_for('index'))


@app.route('/logout')
def logout():
    session.pop('email', None)
    return redirect(url_for('index'))


@app.route('/lists')
def show_lists():
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    sql = "select * from table(show_lists.user_lists(:user_id))"
    cursor.execute(sql, user_id = user_id)
    lists = cursor.fetchall()

    return render_template('lists.html', lists=lists)


@app.route('/lists', methods=['POST'])
def create_list():
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    sql = f"select count(*) from lists where deleted = 0 AND user_id = {user_id}"
    cursor.execute(sql)
    lists_count = cursor.fetchall()[0][0]
    if lists_count >= 21:
        flash('You can create only 20 lists!')
        return redirect(url_for('show_lists'))

    name = request.form['name']
    cursor.callproc('lists_pack.add_list', [name, user_id])
    db.commit()

    return redirect(url_for('show_lists'))


@app.route('/lists/<id>')
def show_list(id):
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    sql = f"SELECT list_id, list_name FROM lists WHERE user_id={user_id} AND list_id={id}"
    cursor.execute(sql)
    task_list = cursor.fetchall()[0]

    sql = "select * from table(show_tasks.user_tasks(:list_id))"
    cursor.execute(sql, list_id = task_list[0])
    tasks = cursor.fetchall()

    completed = [task for task in tasks if task[2]]
    incompleted = [task for task in tasks if not task[2]]

    return render_template('list.html', task_list=task_list, incompleted=incompleted, completed=completed)


@app.route('/lists/<id>/delete', methods=["POST"])
def delete_list(id):
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    cursor.callproc('lists_pack.delete_list', [id])
    db.commit()

    return redirect(url_for('show_lists'))


@app.route('/tasks', methods=['POST'])
def create_task():
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    name = request.form['name']
    description = request.form['description']
    due_date = request.form['due_date']
    d_date = (datetime.datetime.strptime(request.form['due_date'], '%Y-%m-%d').date()) if due_date else None
    due_date = f"'{due_date}'" if due_date else 'NULL'
    list_id = request.form['list_id']
    if request.form['due_date']:
        dd = datetime.datetime.strptime(request.form['due_date'], '%Y-%m-%d').date()    
        if dd < datetime.date.today():
            return redirect(url_for('show_list', id=list_id))

    sql = f"select count(*) from tasks where deleted = 0 AND checked = 0 AND list_id = {list_id}"
    cursor.execute(sql)
    lists_count = cursor.fetchall()[0][0]
    if lists_count >= 101:
        flash('You can create only 100 tasks!')
        return redirect(url_for('show_list'))

    cursor.callproc('tasks_pack.add_task', [list_id, name, description, d_date])
    db.commit()

    return redirect(url_for('show_list', id=list_id))


@app.route('/tasks/<id>/check', methods=['POST'])
def check_task(id):
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    cursor.callproc('tasks_pack.check_task', [id])
    db.commit()

    list_id = request.form['list_id']
    return redirect(url_for('show_list', id=list_id) )


@app.route('/tasks/<id>/uncheck', methods=['POST'])
def uncheck_task(id):
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    sql = f"UPDATE tasks SET checked=0 WHERE task_id={id}"
    cursor.execute(sql)
    db.commit()

    list_id = request.form['list_id']
    return redirect(url_for('show_list', id=list_id) )


@app.route('/tasks/<id>/delete', methods=["POST"])
def delete_task(id):
    if not 'email' in session:
        return redirect(url_for('index'))

    sql = f"SELECT user_id FROM users WHERE email='{session['email']}'"
    cursor.execute(sql)
    user_id = cursor.fetchall()[0][0]

    cursor.callproc('tasks_pack.delete_task', [id])
    db.commit()

    list_id = request.form['list_id']
    return redirect(url_for('show_list', id=list_id) )


@app.route('/statistics')
def dashboard():
    import matplotlib.pyplot as plt
    import mpld3
    #import numpy as np

    #cursor = "Hi Julia, please help me! I want to become cursor one day, but I don't know how to do that :("
    sql = "select * from table(statistic_pack.check_tasks)"
    cursor.execute(sql)
    tasks_by_checked = cursor.fetchall()

    completed = [task[1] for task in tasks_by_checked if task[2]]
    incompleted = [task[1] for task in tasks_by_checked if not task[2]]

    x = [task[1] for task in tasks_by_checked]
    labels = [f"user {task[0]}" for task in tasks_by_checked]

    fig = plt.figure(figsize=(5, 5))
    positions = range(len(completed))
    bar_width = 0.35
    new_positions = [p + bar_width for p in positions]

    res1 = plt.bar(positions, completed, bar_width, color='purple', label = 'completed')
    res2 = plt.bar(new_positions, incompleted, bar_width, color='blue', label = 'incompleted')

    label_positions = [p + (bar_width/2) for p in positions]

    plt.xlabel('Person')
    plt.ylabel('Tasks')
    plt.xticks(label_positions, labels)
    plt.legend()
    tasks_by_checked_chart = mpld3.fig_to_html(fig)


    #cursor = "Hi Julia, please help me! I want to become cursor one day, but I don't know how to do that :("
    sql = "select * from table(statistic_pack.count_lists)"
    cursor.execute(sql)
    lists_by_user = cursor.fetchall()

    x = [task[1] for task in lists_by_user]
    labels = [f"user {task[0]}" for task in lists_by_user]

    fig = plt.figure(figsize=(5, 5))
    positions = range(len(x))
    plt.bar(positions, x, color='purple')

    plt.xlabel('Person')
    plt.ylabel('Lists')
    plt.xticks(positions, labels)
    lists_by_user_chart = mpld3.fig_to_html(fig)


    context = {
      'tasks_by_checked_chart': tasks_by_checked_chart,
      'lists_by_user_chart': lists_by_user_chart,
    }

    return render_template('statistics.html', **context)


from flask_wtf import FlaskForm
from wtforms import IntegerField, SubmitField, PasswordField, validators


class user_age_form(FlaskForm):
    user_id = IntegerField('ID', validators=[validators.DataRequired('Please, enter ID field')])
    new_age = IntegerField('New user age', validators=[validators.DataRequired('Please, enter user new age')])

    submit = SubmitField('Update')


@app.route('/new_age', methods=['GET', 'POST'])
def new_user_age():
    form = user_age_form()

    if form.validate_on_submit():
        u_id = form.user_id.data
        u_n_age = form.new_age.data
        #print(u_n_age)
        cursor.callproc('update_age.new_age', [u_id, u_n_age])
        db.commit()
        return redirect(url_for('index'))


    return render_template('new_age.html', form=form)



