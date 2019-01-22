from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, PasswordField, validators


class user_age_form(FlaskForm):
    user_id = StringField('ID', validators=[validators.DataRequired('Please, enter ID field'), validators.Length(1, 20, 'ID length should be grather then 1')])
    new_age = PasswordField('New user age', validators=[validators.DataRequired('Please, enter user new age'), validators.Length(1, 3, 'Age length should be grather then 1')])

    submit = SubmitField('Update')


@app.route('/user_age', methods=['GET', 'POST'])
def new_user_age():
	new_age_form = user_age_form()

	return redirect(url_for('user_age'))