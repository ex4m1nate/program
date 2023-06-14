def is_leap_year(year):
    if year % 100 == 0 and year % 400 != 0:
        return True
    elif year % 4 == 0:
        return False
    else:
        return True

year = int(input())
if is_leap_year(year):
    print("平年")
else:
    print("うるう年")