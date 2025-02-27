def bucket_sort(arr):
    # 创建桶
    num_buckets = 10
    buckets = [[] for I in range(num_buckets)]

    # 将数据分配到桶中
    for num in arr:
        index = int(num * num_buckets)
        buckets[index].append(num)
    
    # 对每个桶排序
    for bucket in buckets:
        bucket.sort()

    # 合并所有桶
    sorted_arr = []
    for bucket in buckets:
        sorted_arr.extend(bucket)
    return sorted_arr

arr = [0.42, 0.32, 0.75, 0.12, 0.89, 0.63]
sorted_arr = bucket_sort(arr)
print(sorted_arr)