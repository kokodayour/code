import sys

sys.path.append('..')
import os
from common.np import *


def preprocess(text):
    text = text.lower()
    text = text.replace('.', ' .')
    words = text.split(' ')

    word_to_id = {}
    id_to_word = {}
    for word in words:
        if word not in word_to_id:
            new_id = len(word_to_id)
            word_to_id[word] = new_id
            id_to_word[new_id] = word

    corpus = np.array([word_to_id[w] for w in words])
    return corpus, word_to_id, id_to_word


def cos_similarity(x, y, eps=1e-8):
    """计算余弦相似度

    :param x: 向量
    :param y: 向量
    :param eps: 用于防止"除数为0"的微小值
    :return:

    """
    nx = x / (np.sqrt(np.sum(x ** 2)) + eps)
    ny = y / (np.sqrt(np.sum(y ** 2)) + eps)
    return nx @ ny

def convert_one_hot(corpus, vocab_size):
    """
    转换为one-hot表示
    :param corpus: 单词ID列表(一维或二维的numpy数组)
    :param vocab_size: 词汇个数
    :return: one-hot表示(二维或三维的numpy数组)
    """
    N = corpus.shape[0]

    if corpus.ndim == 1:
        one_hot = np.zeros((N,vocab_size), dtype=np.int32)
        for idx, word_id in enumerate(corpus):
            one_hot[idx, word_id] = 1

    elif corpus.ndim == 2:
        C = corpus.shape[1]
        one_hot = np.zeros((N,C,vocab_size),dtype=np.int32)
        for idx_0, word_id in enumerate(corpus):
            for idx_1, word_id_1 in enumerate(word_id):
                one_hot[idx_0, idx_1, word_id_1] = 1
    return one_hot

def create_co_matrix(corpus,vocab_size,window_size=1):
    """生成共线矩阵

    :param corpus: 语料库(单词ID列表)
    :param vocab_size: 词汇个数
    :param window_size: 窗口大小(当窗口大小为1时 左右各1个单词为上下文
    :return 共线矩阵
    """
    corpus_size = len(corpus)
    co_matrix = np.zeros((vocab_size, vocab_size), dtype=np.int32)

    for idx, word_id in enumerate(corpus):
        for i in range(1, window_size + 1):
            left_idx = idx - i
            right_idx = idx + i

            if left_idx >= 0:
                left_word_id = corpus[left_idx]
                co_matrix[word_id, left_word_id] += 1

            if right_idx < corpus_size:
                right_word_id = corpus[right_idx]
                co_matrix[word_id, right_word_id] += 1
    return co_matrix

def create_contexts_target(corpus, window_size=1):
    """
    生成上下文和目标词
    :param corpus: 语料库(单词ID列表)
    :param window_size: 窗口大小(当窗口大小为1时 左右各1个单词为上下文)
    :return:
    """
    target = corpus[window_size:-window_size]
    contexts = []

    for idx in range(window_size, len(corpus)-window_size):
        cs = []
        for t in range(-window_size, window_size + 1):
            if t == 0:
                continue
            cs.append(corpus[idx + t])
        contexts.append(cs)

    return np.array(contexts), np.array(target)
