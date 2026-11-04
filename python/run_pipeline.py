import time
from clean import clean
from validate import validate
from load_mysql import load
from report import build_report


def main():
    start = time.time()
    df = clean()
    validate(df)
    load(df)
    build_report()
    print(f"Pipeline finished in {time.time() - start:.1f} seconds")


if __name__ == "__main__":
    main()
