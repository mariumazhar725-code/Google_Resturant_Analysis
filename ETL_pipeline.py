import pandas as pd
from sqlalchemy import create_engine,text
import psycopg2

#   CONNECTION
username = 'postgres'
password = 'Momina123'
host = 'localhost'
port = '5432'
database = 'restaurant_db'
engine = create_engine(f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}")

with engine.connect():
    print("Connected Successfully to Restaurant_db")


# Extract Data
train = pd.read_csv('google_restaurant_tain.csv')
val = pd.read_csv('google_restaurant_val.csv')
test = pd.read_csv('google_restaurant_test.csv')
BusinessID = pd.read_csv('BusinessID.csv')
UserID = pd.read_csv('UserID.csv')
Rating = pd.read_csv('Rating.csv')
Reviews = pd.read_csv('Reviews.csv')
Pics = pd.read_csv('Pics.csv')



train.to_csv('google_restaurant_tain.csv',index=False)
val.to_csv('google_restaurant_val.csv',index=False)
test.to_csv('google_restaurant_test.csv',index=False)
BusinessID.to_csv('BusinessID.csv',index=False)
UserID.to_csv('UserID.csv',index=False)
Rating.to_csv('Rating.csv',index=False)
Reviews.to_csv('Reviews.csv',index=False)
Pics.to_csv('Pics.csv',index=False)
print("Extracted successfully")


# Transformation
train["business_id"] = train["business_id"].astype(str)
train["user_id"] = train["user_id"].astype(str)
val["business_id"] = val["business_id"].astype(str)
val["user_id"] = val["user_id"].astype(str)
test["business_id"] = test["business_id"].astype(str)
test["user_id"] = test["user_id"].astype(str)
UserID["user_id"] = UserID["user_id"].astype(str)
BusinessID["business_id"] = BusinessID["business_id"].astype(str)
print("Transformed successfully")

# Load data
tables = {
    'train': train,
    'validation': val,
    'test':test,
    'business_id':BusinessID,
    'user_id':UserID,
    'rating':Rating,
    'reviews':Reviews,
    'pics':Pics
}

for table_name, df in tables.items():
    try:
        with engine.begin() as conn:
            conn.execute(text(f'TRUNCATE TABLE "{table_name}" RESTART IDENTITY CASCADE'))
            df.to_sql(
                name = table_name,
                con = conn,
                if_exists = 'append',
                index = False,
            )
            print(f"{table_name} imported successfully with {len(df)} rows")
    except Exception as e:
           print(f"error in {table_name}: {e}")

print("Pipeline completed successfully")


