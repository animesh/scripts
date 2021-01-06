#code https://towardsdatascience.com/creating-an-email-parser-with-python-and-sql-c79cb8771dac
#data outlooks mail copied to folder
#check https://sqlite.org/cli.html
#pip install sqlalchemy
db = sqlite3.connect("emails.db")
# Create empty tables
db.execute("""
CREATE TABLE IF NOT EXISTS "articles" (
"id" INTEGER,
"title" TEXT UNIQUE,
"publication" TEXT,
PRIMARY KEY("id" AUTOINCREMENT))
""")
db.execute("""
CREATE TABLE IF NOT EXISTS "links" (
"article_id"    INTEGER,
"link0" TEXT,
"link1" TEXT,
"link2" TEXT,
PRIMARY KEY("article_id"))
""")
db.execute("""
CREATE TABLE IF NOT EXISTS "platforms" (
"article_id"    INTEGER,
"platform0" TEXT,
"platform1" TEXT,
"platform2" TEXT,
PRIMARY KEY("article_id"))
""")
folder_path = r"C:\\Users\\Username\\EmailFolder"
folder_path = os.path.normpath(askdirectory(title='Select Folder'))
email_list =
[file for file in os.listdir(folder_path) if file.endswith(".msg")]
# Connect to Outlook with MAPI
outlook = win32com.client.Dispatch(“Outlook.Application”).GetNamespace(“MAPI”)
# Iterate through every email
for i, _ in enumerate(email_list):
   # Create variable storing info from current email being parsed
   msg = outlook.OpenSharedItem(os.path.join(folder_path,
   email_list[i]))
   # Search email HTML for body text
   regex = re.search(r"<body([\s\S]*)</body>", msg.HTMLBody)
   body = regex.group()
pattern = r"li class=MsoListParagraph([\s\S]*?)</li>"
results = re.findall(pattern, body)
regex = re.search(r"[^<>]+(?=\(|sans-serif’>([\s\S]*?)</span>)", header)
# HTML unescape to get remove remaining HTML
title_pub = html.unescape(regex.group())
title = split_list[0].strip()
publication = split_list[1].strip()
# List of publications to check for
platform_list = ["Online", "Facebook", "Instagram", "Twitter", "LinkedIn", "Linkedin", "Youtube"]
# Create empty list to store publications
platform = []
# Iterate and check for each item in my first list
for p in platform_list:
   if p in header:
      platform.append(p)
# Find all links using regex
links = re.findall(r"<a href=\”([\s\S]*?)\”>", header)
# Insert title & pub by substituting values into each ? placeholder
db.execute("INSERT INTO articles (title, publication)
VALUES (?, ?)", (title, publication))
# Get article id and copy to platforms & links tables
article_id = db.execute(“SELECT id FROM articles WHERE title = ?”, (title,))
for item in article_id:
   _id = item[0]
for i, _ in enumerate(platform):
   db.execute(f”UPDATE platforms SET platform{i} = ? WHERE
   article_id = ?”, (platform[i], _id))
for i, _ in enumerate(links):
   db.execute(f”UPDATE links SET link{i} = ? WHERE article_id = ?”,
   (links[i], _id))
# Commit changes
db.commit()
#https://github.com/benjamin-awd/OutlookParser50/blob/main/Demo/s_parser.py
import sqlalchemy as db
engine = db.create_engine('sqlite:///C:\\Users\\animeshs\\GD\\scripts\\census.sqlite')
connection = engine.connect()
metadata = db.MetaData()
census = db.Table('census', metadata, autoload=True, autoload_with=engine)
print(census.columns.keys())
print(repr(metadata.tables['census']))
query = db.select([census])
ResultProxy = connection.execute(query)
ResultSet = ResultProxy.fetchall()
ResultSet[:3]
#Equivalent to 'SELECT * FROM census'
while flag:
    partial_results = ResultProxy.fetchmany(50)
    if(partial_results == []):
	flag = False
ResultProxy.close()
female_pop = db.func.sum(db.case([(census.columns.sex == 'F', census.columns.pop2000)],else_=0))
query = db.select([female_pop/total_pop * 100])
total_pop = db.cast(db.func.sum(census.columns.pop2000), db.Float)
result = connection.execute(query).scalar()
print(result)#51.09467432293413v51.09467432293413
state_fact = db.Table('state_fact', metadata, autoload=True, autoload_with=engine)
query = db.select([census.columns.pop2008, state_fact.columns.abbreviation])
results = connection.execute(query).fetchall()
df = pd.DataFrame(results)
df.columns = results[0].keys()
df.head(5)
sql = "SELECT * FROM census;"
df = pd.read_sql_query(sql, engine)#.set_index('index')
# shuffle dataset, preserving index
df.sample(6)

#sql = "SELECT TOP 1 * FROM census ORDER BY newid()"
#https://stackoverflow.com/a/1253576
sql = "SELECT * FROM census ORDER BY RANDOM() limit 6"
pd.read_sql_query(sql, engine)#.set_index('index')
# shuffle dataset, preserving index
dfSample = df.sample(5)

engine = db.create_engine('sqlite:///test.sqlite') #Create test.sqlite automatically
connection = engine.connect()
metadata = db.MetaData()
emp = db.Table('emp', metadata,
              db.Column('Id', db.Integer()),
              db.Column('name', db.String(255), nullable=False),
              db.Column('salary', db.Float(), default=100.0),
              db.Column('active', db.Boolean(), default=True)
              )
metadata.create_all(engine) #Creates the table
#Inserting record one by one
query = db.insert(emp).values(Id=1, name='naveen', salary=60000.00, active=True)
ResultProxy = connection.execute(query)
In [ ]:
#Inserting many records at ones
query = db.insert(emp)
values_list = [{'Id':'2', 'name':'ram', 'salary':80000, 'active':False},
               {'Id':'3', 'name':'ramesh', 'salary':70000, 'active':True}]
ResultProxy = connection.execute(query,values_list)
In [43]:
results = connection.execute(db.select([emp])).fetchall()
df = pd.DataFrame(results)
df.columns = results[0].keys()
df.head(4)

train_frac = 0.9
test_frac = 1 - train_frac

trn_cutoff = int(len(df) * train_frac)

df_trn = df[:trn_cutoff]
df_tst = df[trn_cutoff:]

df_trn.to_sql('trn_set', engine, if_exists='replace')
df_tst.to_sql('tst_set', engine, if_exists='replace')

df_online = pd.read_csv("data/online.csv")
df_online.to_sql('Online', engine, if_exists='replace')

df_order = pd.read_csv("data/Order.csv")
df_order.to_sql('Purchase', engine, if_exists='replace')
#select count(*) from trn_set;
#select count(*) from tst_set;
#select count(*) from tst_set;select * from trn_set limit 5;
USE Shutterfly;

DROP TABLE IF EXISTS features_group_1;

CREATE TABLE IF NOT EXISTS features_group_1
SELECT o.index
  ,LEFT(o.dt, 10) AS day
  ,COUNT(*) AS order_count
  ,SUM(p.revenue) AS revenue_sum
  ,MAX(p.revenue) AS revenue_max
  ,MIN(p.revenue) AS revenue_min
  ,SUM(p.revenue) / COUNT(*) AS rev_p_order
  ,COUNT(p.prodcat1) AS prodcat1_count
  ,COUNT(p.prodcat2) AS prodcat2_count
  ,DATEDIFF(o.dt, MAX(p.orderdate)) AS days_last_order
  ,DATEDIFF(o.dt, MAX(CASE WHEN p.prodcat1 IS NOT NULL THEN p.orderdate ELSE NULL END)) AS days_last_prodcat1
  ,DATEDIFF(o.dt, MAX(CASE WHEN p.prodcat2 IS NOT NULL THEN p.orderdate ELSE NULL END)) AS days_last_prodcat2
  ,SUM(p.prodcat1 = 1) AS prodcat1_1_count
  ,SUM(p.prodcat1 = 2) AS prodcat1_2_count
  ,SUM(p.prodcat1 = 3) AS prodcat1_3_count
  ,SUM(p.prodcat1 = 4) AS prodcat1_4_count
  ,SUM(p.prodcat1 = 5) AS prodcat1_5_count
  ,SUM(p.prodcat1 = 6) AS prodcat1_6_count
  ,SUM(p.prodcat1 = 7) AS prodcat1_7_count
FROM Online AS o
JOIN Purchase AS p
  ON o.custno = p.custno
  AND p.orderdate <= o.dt
GROUP BY o.index;

ALTER TABLE `features_group_1`
  ADD KEY `ix_features_group_1_index` (`index`);
#show tables;
def load_dataset(split="trn_set", limit=None, ignore_categorical=False):
    sql = """
    SELECT o.*, f1.*, f2.*, f3.*, f4.*,
    EXTRACT(MONTH FROM o.dt) AS month
    FROM %s AS t
    JOIN Online AS o
        ON t.index = o.index
    JOIN features_group_1 AS f1
        ON t.index = f1.index
    JOIN features_group_2 AS f2
        ON t.index = f2.index
    JOIN features_group_3 AS f3
        ON t.index = f3.index
    JOIN features_group_4 AS f4
        ON t.index = f4.index
    """%split
    if limit:
        sql += " LIMIT %i"%limit

    df = pd.read_sql_query(sql.replace('\n', " ").replace("\t", " "), engine)
    df.event1 = df.event1.fillna(0)
    X = df.drop(["index", "event2", "dt", "day", "session", "visitor", "custno"], axis=1)
    Y = df.event2
    return X, Y
