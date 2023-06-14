user = 'ozawa'
userpass = 'passward'
inputname = input('ユーザ名を入力してください: ')
inputpass = input('パスワードを入力してください: ')
if user == inputname:
    if userpass == inputpass:
        print('ログイン成功')
    else:
        print('パスワードが不正です')
else:
    print('ユーザ名が不正です')