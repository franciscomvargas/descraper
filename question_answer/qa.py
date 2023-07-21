import requests

# Run Model NeuralQA
def neuralqa_req(context, questions, expansionterms=[], neuralqa_port=8888, reader='distilbert'):
    url = f"http://127.0.0.1:{neuralqa_port}/api/answers"
    if reader == 'distilbert':
        model = "twmkn9/distilbert-base-uncased-squad2"
    elif reader == 'bert':
        model = "deepset/bert-base-cased-squad2"
    else:
        print("Invalid Reader!\nValid Readers: ['distilbert', 'bert']")
        return None
    result = list()
    for count, question in enumerate(questions):
        print(f"Processing question: {question}")
        payload = {
            "max_documents": 5,
            "context": context,
            "query": question,
            "fragment_size": 350,
            "reader": model,
            "retriever": "none",
            "tokenstride": 0,
            "relsnip": True,
            "expansionterms": expansionterms[count] if expansionterms != [] else []
        }
        response = requests.request("POST", url, json=payload)
        # print(f"Payload:\n{payload}")
        print(f"Qtty of answers = {len(response.json()['answers'])}\n")
        result.append(response.json())
    return result

# Get Query Expansion
def neuralqa_expand(questions, neuralqa_port=8888):
    url = f"http://127.0.0.1:{neuralqa_port}/api/expand"
    result = list()
    for question in questions:
        payload = {
            "query": question
        }
        response = requests.request("POST", url, json=payload)
        result.append(response.json())
    return result
