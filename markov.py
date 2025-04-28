import random
import json

# ==============
#  markov chain
# ==============

def generate(tokenCount):
    weights = []

    for a in range(tokenCount):
        weights.append([])

        for b in range(tokenCount + 1):
            weights[a].append(0)

    return weights

def train(weights, data):
    for sentence in data:
        for a in range(len(sentence) - 1):
            current = sentence[a]
            next    = sentence[a + 1]

            weights[current][next] += 1

        weights[sentence[-1]][len(weights)] += 1

    for f in weights:
        divisor = sum(f)

        for a in range(len(f)):
            f[a] /= divisor

def choose(weights, r):
    choice = 0
    floor  = 0

    for weight in weights:
        if r >= floor and r < floor + weight:
            return choice

        choice += 1
        floor  += weight

    return choice

def run(weights, token):
    l    = []
    stop = len(weights)

    while token != stop:
        l.append(token)
        token = choose(weights[token], random.random())

    return l

# =================
#  data and tokens
# =================

def loadJSON(path):
    file = open(path, "r")
    data = json.load(file)
    file.close()

    return data

def toTokens(data):
    number = 0
    tokens = {}
    words  = []

    for sentence in data:
        for word in sentence.split():
            if not word in tokens:
                tokens[word] = number
                number      += 1

                words.append(word)

    return {"tokens": tokens, "words": words, "count": len(words)}

def tokenize(data, tokens):
    tokenized = []

    for sentence in data:
        index = len(tokenized)
        tokenized.append([])

        for word in sentence.split():
            tokenized[index].append(tokens["tokens"][word])

    return tokenized

def getStarts(tokenized):
    starts = []

    for sentence in tokenized:
        start = sentence[0]

        if not start in starts:
            starts.append(start)

    return starts

def decode(tokens, l):
    sentence = []

    for token in l:
        sentence.append(tokens["words"][token])

    return " ".join(sentence)

# ======
#  main
# ======

def go(tokens, weights, starts):
    start    = starts[random.randint(0, len(starts) - 1)]
    sentence = decode(tokens, run(weights, start))

    print(sentence)

path = input("path: ")

i      = loadJSON(path)
tokens = toTokens(i)
data   = tokenize(i, tokens)
starts = getStarts(data)

weights = generate(tokens["count"])
train(weights, data)

print(len(weights))

for a in range(int(input("runs: "))):
    go(tokens, weights, starts)
