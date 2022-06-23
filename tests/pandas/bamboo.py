import pandas as pd

def dataframe_example():
    data = {
        "odds": [1, 3, 5, 7],
        "evens": [2, 4, 6, 8],
    }
    df = pd.DataFrame(data)
    return (df.loc[0][1])


if __name__ == "__main__":
    print(f'The Mainframe says: {dataframe_example()}')
