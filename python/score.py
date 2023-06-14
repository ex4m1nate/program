subjects = ["国語", "数学", "理科", "日本史", "世界史", "地理", "英語"]
scores = []

def register_scores():

    for i in range(int(len(subjects))):
        score = input(subjects[i] + "の点数を入力:")
        scores.append(int(score))
    return scores

result = register_scores()
print(result)

total = sum(scores)
avarage = total / int(len(subjects))
print("合計点" + str(total))
print("平均点" + str(avarage))