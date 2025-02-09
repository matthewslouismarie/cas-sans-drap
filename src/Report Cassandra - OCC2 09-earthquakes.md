## Clone the GitHub Repository

To clone this repository using SSH:

1. **Add your SSH key to GitHub**:
- Copy your **public SSH key** to your clipboard. If you don't have one, [generate an SSH key](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).
- Add the key to your [GitHub SSH settings](https://github.com/settings/keys).

1. **Test your SSH connection**:

```bash
ssh -T git@github.com
```

2. **Clone the repository**:

```bash
git clone git@github.com:matthewslouismarie/cas-sans-drap.git
```


---

## Connect to Cassandra via Docker

1. **Navigate to the project directory** containing the `docker-compose.yml` file:

```bash
cd /path/to/your/repository
```

2. **Start Cassandra using Docker Compose**:

```bash
docker-compose up -d
```

3. **Verify if Cassandra is running**:

```bash
docker ps
```

4. **Access Cassandra's CQL shell**: To connect to the Cassandra container and access the CQL shell, run:

```bash
docker exec -it cas-sans-drap-cassandra-1 cqlsh
```


---

## Attach VSCode to the Running Container

1. Open **VSCode** and press `Ctrl+Shift+P`.

2. Type and select:

```
Remote-Containers: Attach to Running Container  
```

3. Select the **Cassandra container** from the list.


---

## Creating Tables

**Create the tables** by executing the `create_table.cql` file:

```bash
docker exec -i cas-sans-drap-cassandra-1 cqlsh < src/create_table.cql
```


---

## Populating Tables

To populate the tables, first clean the dataset using Python, and then load the resulting `JSON` file into the database using **DSBulk**.

### Steps to install and use DSBulk:

4. **Download DSBulk**:

```bash
wget https://github.com/datastax/dsbulk/releases/download/1.11.0/dsbulk-1.11.0.tar.gz
```

5. **Extract the downloaded file**:

```bash
tar -zxvf dsbulk-1.11.0.tar.gz
```

6. **Check if Java is installed (DSBulk requires it)**:

```bash
echo $JAVA_HOME
```

7. **Move the DSBulk folder to the `/opt` directory**:

```bash
mv dsbulk-1.11.0/ /opt/
```

8. **Add the DSBulk path to the `PATH` environment variable**:

```bash
echo 'PATH=/opt/dsbulk-1.11.0/bin/:$PATH' >> .profile
```

9. **Reload the shell to apply the changes**:

```bash
source .profile
```

10. **Populate the table**:

```bash
dsbulk load -c json -url project/merged_df.json -k ks -t earthquakes
```


---

## Running Queries

**Execute queries** by running the `queries.cql` file:

```bash
docker exec -i cas-sans-drap-cassandra-1 cqlsh < src/queries.cql
```


---

## Queries

For easier readability we will not put the outputs of every queries, only the shorter ones.

### Simple Queries

1. Select the first 5 rows from the earthquakes table
```sql
SELECT * FROM earthquakes LIMIT 5;
```

2. Select only the 'place' and 'mag' columns from the earthquakes table, limiting to the first 5 rows
```sql
SELECT place, mag FROM earthquakes LIMIT 5;
```

| place                                         | mag |
| --------------------------------------------- | --- |
| 129km W of Cantwell, Alaska                   | 0.9 |
| 2km ENE of Colton, California                 | 2.3 |
| 16km WSW of Big Lake, Alaska                  | 1.2 |
| 35km NW of Circle Hot Springs Station, Alaska | 1.3 |
| 10km WNW of Calipatria, California            | 0.8 |

3. Select a specific earthquake by its 'id' (efficient query since 'id' is the primary key)
```sql
SELECT * FROM earthquakes WHERE id = 'usb000hc3b';
```

| id         | alert | cdi  | code     | coordinates                | detail                                                                             | dmin | felt | gap | ids            | mag | magtype | mmi  | net | nst | place                                  | rms  | sig | sources | status   | time       | tsunami | type       | types                                                                                                                                           | tz  | updated    | url                                                                 |
| ---------- | ----- | ---- | -------- | -------------------------- | ---------------------------------------------------------------------------------- | ---- | ---- | --- | -------------- | --- | ------- | ---- | --- | --- | -------------------------------------- | ---- | --- | ------- | -------- | ---------- | ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | --- | ---------- | ------------------------------------------------------------------- |
| usb000hc3b | null  | null | b000hc3b | (154.1212, -6.6583, 24.83) | [Link](http://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/usb000hc3b.geojson) | 3.13 | null | 64  | ['usb000hc3b'] | 4.7 | mb      | null | us  | 31  | 155km WSW of Panguna, Papua New Guinea | 1.05 | 340 | ['us']  | REVIEWED | 1.3702e+12 | null    | earthquake | ['cap', 'dyfi', 'general-link', 'geoserve', 'nearby-cities', 'origin', 'p-wave-travel-times', 'phase-data', 'scitech-link', 'tectonic-summary'] | 600 | 1370253974 | [Link](http://earthquake.usgs.gov/earthquakes/eventpage/usb000hc3b) |

4. Query the first 5 earthquakes with 'mag' greater than 5.0 and 'status' equal to 'REVIEWED'
```sql
SELECT * FROM earthquakes WHERE mag > 5.0 AND status = 'REVIEWED' ALLOW FILTERING LIMIT 5;
```

5. Count the number of earthquakes with 'mag' greater than 5 (ALLOW FILTERING is inefficient and should be avoided where possible)
```sql
SELECT COUNT(*) FROM earthquakes WHERE mag > 5 ALLOW FILTERING;
```

|count|
|---|
|99|
6. Query earthquakes by 'place' using the secondary index on 'place' (secondary indexes are less efficient than primary key queries but more efficient than using ALLOW FILTERING)
```sql
CREATE INDEX IF NOT EXISTS place_index ON earthquakes (place);
SELECT * FROM earthquakes WHERE place = '6km ENE of Desert Hot Springs, California';
```

| id         | alert | cdi  | code     | coordinates              | detail                                                                             | dmin     | felt | gap  | ids            | mag | magtype | mmi  | net | nst | place                                     | rms  | sig | sources | status    | time       | tsunami | type       | types                                                                   | tz   | updated    | url                                                                 |
| ---------- | ----- | ---- | -------- | ------------------------ | ---------------------------------------------------------------------------------- | -------- | ---- | ---- | -------------- | --- | ------- | ---- | --- | --- | ----------------------------------------- | ---- | --- | ------- | --------- | ---------- | ------- | ---------- | ----------------------------------------------------------------------- | ---- | ---------- | ------------------------------------------------------------------- |
| ci15353289 | null  | null | 15353289 | (-116.4387, 33.983, 7.2) | [Link](http://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/ci15353289.geojson) | 0.044916 | null | 61.2 | ['ci15353289'] | 1.1 | Ml      | null | ci  | 19  | 6km ENE of Desert Hot Springs, California | 0.06 | 19  | ['ci']  | AUTOMATIC | 1.3703e+12 | null    | earthquake | ['general-link', 'geoserve', 'nearby-cities', 'origin', 'scitech-link'] | -420 | 1370254362 | [Link](http://earthquake.usgs.gov/earthquakes/eventpage/ci15353289) |

### Complex Queries

### Hard Queries