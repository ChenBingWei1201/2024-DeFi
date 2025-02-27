# Define the pools and reserves
pools = {
    ('A', 'B'): (17, 10),
    ('A', 'C'): (11, 7),
    ('A', 'D'): (15, 9),
    ('A', 'E'): (21, 5),
    ('B', 'C'): (36, 4),
    ('B', 'D'): (13, 6),
    ('B', 'E'): (25, 3),
    ('C', 'D'): (30, 12),
    ('C', 'E'): (10, 8),
    ('D', 'E'): (60, 25),
    # Add reverse pools for bidirectional swaps
    ('B', 'A'): (10, 17),
    ('C', 'A'): (7, 11),
    ('D', 'A'): (9, 15),
    ('E', 'A'): (5, 21),
    ('C', 'B'): (4, 36),
    ('D', 'B'): (6, 13),
    ('E', 'B'): (3, 25),
    ('D', 'C'): (12, 30),
    ('E', 'C'): (8, 10),
    ('E', 'D'): (25, 60),
}

def calculate_amount_out(amount_in, reserve_in, reserve_out):
    amount_in_with_fee = amount_in * 997
    numerator = amount_in_with_fee * reserve_out
    denominator = reserve_in * 1000 + amount_in_with_fee
    return numerator // denominator

def update_reserves(pools, token1, token2, amount_in, amount_out):
    reserve_in, reserve_out = pools[(token1, token2)]
    pools[(token1, token2)] = (reserve_in + amount_in, reserve_out - amount_out)
    pools[(token2, token1)] = (reserve_out - amount_out, reserve_in + amount_in)

def find_best_path(start_token, start_amount, target_token, pools, max_depth=7):
    max_amount = 0
    best_path = []
    
    # Use a queue for BFS
    queue = [(start_token, start_amount, [], dict(pools))]
    
    while queue:
        current_token, current_amount, path, current_pools = queue.pop(0)
        
        if len(path) > max_depth:
            continue
        
        if current_token == target_token and current_amount > max_amount:
            max_amount = current_amount
            best_path = path
        
        for (token1, token2), (reserve1, reserve2) in current_pools.items():
            if current_token == token1:
                amount_out = calculate_amount_out(current_amount, reserve1, reserve2)
                if amount_out > 0:  # Ensure the swap is valid
                    new_pools = dict(current_pools)
                    update_reserves(new_pools, token1, token2, current_amount, amount_out)
                    queue.append((token2, amount_out, path + [(token1, token2)], new_pools))
    
    return best_path, max_amount

# Find the best path starting with 5 units of token B
best_path, max_amount = find_best_path('B', 5, 'B', pools)
print("Best Path:", best_path)
print("Max Amount of B:", max_amount)