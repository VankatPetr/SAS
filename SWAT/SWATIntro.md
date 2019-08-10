
# Intro

The SAS Scripting Wrapper for Analytics Transfer (SWAT) is a package developed by SAS to allow the Python interface to access the SAS Viya platform and use its processing power. What is SAS Viya? It is a cloud-ready, in-memory analytics engine using SAS Cloud Analytic Services, or CAS for short.

So, if you have no SAS background, don’t worry, the following steps demonstrate how you can use your Python skills to utilize and control analytical routines in SAS Viya.

# Packages

+ To allow connections to SAS Viya through SWAT, the following additional packages are required.
+ %matplotlib inline will make your plot outputs appear and be stored within the notebook.
+ SWAT.OPTIONS.CAS.PRINT_MESSAGES is a SWAT function that can be used to turn on or off message printing of CAS actions and results.


```python
import swat
import pandas as pd
from matplotlib import pyplot as plt
%matplotlib inline
swat.options.cas.print_messages = True
```

# Connection

+ Connect to CAS using the CASHOST, CASPORT, and SAS_VIYA_TOKEN arguments from the operating system environment.


```python
conn = swat.CAS(os.environ.get("CASHOST"), os.environ.get("CASPORT"),None,os.environ.get("SAS_VIYA_TOKEN"))
```

+ To verify that a connection is now made, the serverstatus CAS action can be run on the CAS session to display details about the current SAS Viya session.


```python
conn.serverstatus()
```

    NOTE: Grid node action status report: 1 nodes, 8 total actions executed.
    




<div class="cas-results-key"><b>&#167; About</b></div>
<div class="cas-results-body">
<div>{'CAS': 'Cloud Analytic Services', 'Version': '3.04', 'VersionLong': 'V.03.04M0P07122018', 'Copyright': 'Copyright © 2014-2018 SAS Institute Inc. All Rights Reserved.', 'ServerTime': '2019-08-10T15:36:14Z', 'System': {'Hostname': 'pdcesx27012', 'OS Name': 'Linux', 'OS Family': 'LIN X64', 'OS Release': '3.10.0-693.el7.x86_64', 'OS Version': '#1 SMP Tue Aug 22 21:09:27 UTC 2017', 'Model Number': 'x86_64', 'Linux Distribution': 'CentOS Linux release 7.4.1708 (Core)'}, 'license': {'site': 'DEMOCENTER - Viya For Learners', 'siteNum': 70180938, 'expires': '05Dec2019:00:00:00', 'gracePeriod': 45, 'warningPeriod': 45, 'maxCPUs': 9999}}</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; server</b></div>
<div class="cas-results-body">
<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe"><caption>Server Status</caption>
  <thead>
    <tr style="text-align: right;">
      <th title=""></th>
      <th title="Node Count">nodes</th>
      <th title="Total Actions">actions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>8</td>
    </tr>
  </tbody>
</table>
</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; nodestatus</b></div>
<div class="cas-results-body">
<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe"><caption>Node Status</caption>
  <thead>
    <tr style="text-align: right;">
      <th title=""></th>
      <th title="Node Name">name</th>
      <th title="Role">role</th>
      <th title="Uptime (Sec)">uptime</th>
      <th title="Running">running</th>
      <th title="Stalled">stalled</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pdcesx27012.exnet.sas.com</td>
      <td>controller</td>
      <td>0.251</td>
      <td>0</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>
</div>
<div class="cas-output-area"></div>
<p class="cas-results-performance"><small><span class="cas-elapsed">elapsed 0.000268s</span> &#183; <span class="cas-user">user 0.000138s</span> &#183; <span class="cas-sys">sys 0.00012s</span> &#183; <span class="cas-memory">mem 0.312MB</span></small></p>



+ Youc can change the CAS time-out for the session, for example to 12 hours.


```python
mytime = 60*60*12
conn.session.timeout(time=mytime)
conn.session.sessionStatus()
```




<div class="cas-results-key"><b>&#167; state</b></div>
<div class="cas-results-body">
<div>Connected</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; number of Connections</b></div>
<div class="cas-results-body">
<div>1</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; Timeout</b></div>
<div class="cas-results-body">
<div>43200</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; ActionStatus</b></div>
<div class="cas-results-body">
<div>Action is active</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; Authenticated</b></div>
<div class="cas-results-body">
<div>Yes</div>
</div>
<div class="cas-results-key"><hr/><b>&#167; locale</b></div>
<div class="cas-results-body">
<div>en_US</div>
</div>
<div class="cas-output-area"></div>
<p class="cas-results-performance"><small><span class="cas-elapsed">elapsed 0.000121s</span> &#183; <span class="cas-user">user 6.1e-05s</span> &#183; <span class="cas-sys">sys 5.1e-05s</span> &#183; <span class="cas-memory">mem 0.212MB</span></small></p>



# Data

+ Data can be already in to CAS. Use fileinfo method to explore the public library and see what datasets are already avilable for you. 
+ To work on a table a CASTable statement needs to be run. This will create a data table object.


```python
conn.fileinfo(caslib='public')
```




<div class="cas-results-key"><b>&#167; FileInfo</b></div>
<div class="cas-results-body">
<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th title=""></th>
      <th title="Permission">Permission</th>
      <th title="Owner">Owner</th>
      <th title="Group">Group</th>
      <th title="Name">Name</th>
      <th title="Size of File in Bytes">Size</th>
      <th title="Encryption Method">Encryption</th>
      <th title="Time">Time</th>
      <th title="ModTime">ModTime</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>-rw-r--r--</td>
      <td>v4e.admin@v4e.sas.com</td>
      <td>sas</td>
      <td>predef_svrtdist.sashdat</td>
      <td>78872</td>
      <td>NONE</td>
      <td>2019-07-18T09:14:53-04:00</td>
      <td>1.879075e+09</td>
    </tr>
    <tr>
      <th>1</th>
      <td>-rwxr-xr-x</td>
      <td>v4e.admin@v4e.sas.com</td>
      <td>sas</td>
      <td>PARKS_LOC.sashdat</td>
      <td>46665928</td>
      <td>NONE</td>
      <td>2019-07-15T08:58:35-04:00</td>
      <td>1.878815e+09</td>
    </tr>
    <tr>
      <th>2</th>
      <td>-rwxr-xr-x</td>
      <td>v4e.admin@v4e.sas.com</td>
      <td>sas</td>
      <td>FACILITY_TOY_AMERICA.sashdat</td>
      <td>15280912</td>
      <td>NONE</td>
      <td>2019-07-15T09:02:47-04:00</td>
      <td>1.878815e+09</td>
    </tr>
    <tr>
      <th>3</th>
      <td>-rwxr-xr-x</td>
      <td>Sharon.Wu@sas.com</td>
      <td>v4e_users</td>
      <td>MQHACK_NEW.sashdat</td>
      <td>5846216</td>
      <td>NONE</td>
      <td>2019-07-24T21:05:44-04:00</td>
      <td>1.879636e+09</td>
    </tr>
  </tbody>
</table>
</div>
</div>
<div class="cas-output-area"></div>
<p class="cas-results-performance"><small><span class="cas-elapsed">elapsed 0.0192s</span> &#183; <span class="cas-user">user 6.3e-05s</span> &#183; <span class="cas-sys">sys 0.00102s</span> &#183; <span class="cas-memory">mem 0.689MB</span></small></p>




```python
MQHACK = conn.CASTable(name='MQHACK_NEW', caslib='public')
```

+ If data is not available, you can load new data by yourself. For example load the hmeq.csv data set onto the server (use a folder path where you store the data) and create a data table object called castbl.
+ Successfull upload will be confirmed by 2 NOTE's. The CASUSER library is a library which will make the data set available to the current user only.


```python
castbl = conn.read_csv(os.environ.get("HOME")+"/Courses/EVMLOPRC/DATA/hmeq.csv", casout = dict(name="hmeq", replace=True))
```

    NOTE: Cloud Analytic Services made the uploaded file available as table HMEQ in caslib CASUSER(vankat.petr@outlook.com).
    NOTE: The table HMEQ has been created in caslib CASUSER(vankat.petr@outlook.com) from binary data uploaded to Cloud Analytic Services.
    

+ It is possible to move data between libraries. For example, once you are done with data analysis/manipulation etc., you can promote the final set to to the public library (target = the name of the new CAS table within the target library).


```python
#conn.promote(name=castbl, targetlib='public', target='HMEQ_MODIFIED')
```

+ If required, you can bring data locally. You can use the type() function in Python to determine where the data is located. Data on the CAS server will have a type or class of CASTable, and data on the client will have a type or class of casDataFrame or sasDataFrame depending on how it was created.


```python
df = MQHACK.to_frame()
```


```python
display(type(MQHACK))
display(type(df))
```


    swat.cas.table.CASTable



    swat.dataframe.SASDataFrame


# SWAT

+ To find out available functions in SWAT, use dir() method. 
+ You can use the Help function to load documentation for a function.


```python
funcs = dir(swat)
funcs[:5]
#help("swat.CAS")
```




    ['CAS', 'CASTable', 'SASDataFrame', 'SASFormatter', 'SWATCASActionError']



### Data Exploration
+ Use SWAT functions to explore the dataset.


```python
display(castbl.info())
castbl.describe(include=['numeric', 'character'])
```

    CASTable('HMEQ', caslib='CASUSER(vankat.petr@outlook.com)')
    Data columns (total 13 columns):
                N   Miss     Type
    BAD      5960  False   double
    LOAN     5960  False   double
    MORTDUE  5442   True   double
    VALUE    5848   True   double
    REASON   5708   True  varchar
    JOB      5681   True  varchar
    YOJ      5445   True   double
    DEROG    5252   True   double
    DELINQ   5380   True   double
    CLAGE    5652   True   double
    NINQ     5450   True   double
    CLNO     5738   True   double
    DEBTINC  4693   True   double
    dtypes: double(11), varchar(2)
    data size: 785334
    vardata size: 70134
    memory usage: 785456
    


    None





<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th title=""></th>
      <th title="BAD">BAD</th>
      <th title="LOAN">LOAN</th>
      <th title="MORTDUE">MORTDUE</th>
      <th title="VALUE">VALUE</th>
      <th title="REASON">REASON</th>
      <th title="JOB">JOB</th>
      <th title="YOJ">YOJ</th>
      <th title="DEROG">DEROG</th>
      <th title="DELINQ">DELINQ</th>
      <th title="CLAGE">CLAGE</th>
      <th title="NINQ">NINQ</th>
      <th title="CLNO">CLNO</th>
      <th title="DEBTINC">DEBTINC</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>5960</td>
      <td>5960</td>
      <td>5442</td>
      <td>5848</td>
      <td>5708</td>
      <td>5681</td>
      <td>5445</td>
      <td>5252</td>
      <td>5380</td>
      <td>5652</td>
      <td>5450</td>
      <td>5738</td>
      <td>4693</td>
    </tr>
    <tr>
      <th>unique</th>
      <td>2</td>
      <td>540</td>
      <td>5053</td>
      <td>5381</td>
      <td>2</td>
      <td>6</td>
      <td>99</td>
      <td>11</td>
      <td>14</td>
      <td>5314</td>
      <td>16</td>
      <td>62</td>
      <td>4693</td>
    </tr>
    <tr>
      <th>top</th>
      <td>0</td>
      <td>15000</td>
      <td>42000</td>
      <td>60000</td>
      <td>DebtCon</td>
      <td>Other</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>206.967</td>
      <td>0</td>
      <td>16</td>
      <td>203.312</td>
    </tr>
    <tr>
      <th>freq</th>
      <td>4771</td>
      <td>105</td>
      <td>11</td>
      <td>15</td>
      <td>3928</td>
      <td>2388</td>
      <td>415</td>
      <td>4527</td>
      <td>4179</td>
      <td>7</td>
      <td>2531</td>
      <td>316</td>
      <td>1</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>0.199497</td>
      <td>18608</td>
      <td>73760.8</td>
      <td>101776</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>8.92227</td>
      <td>0.25457</td>
      <td>0.449442</td>
      <td>179.766</td>
      <td>1.18606</td>
      <td>21.2961</td>
      <td>33.7799</td>
    </tr>
    <tr>
      <th>std</th>
      <td>0.399656</td>
      <td>11207.5</td>
      <td>44457.6</td>
      <td>57385.8</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>7.57398</td>
      <td>0.846047</td>
      <td>1.12727</td>
      <td>85.8101</td>
      <td>1.72867</td>
      <td>10.1389</td>
      <td>8.60175</td>
    </tr>
    <tr>
      <th>min</th>
      <td>0</td>
      <td>1100</td>
      <td>2063</td>
      <td>8000</td>
      <td>DebtCon</td>
      <td>Mgr</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.524499</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>0</td>
      <td>11100</td>
      <td>46268</td>
      <td>66069</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>3</td>
      <td>0</td>
      <td>0</td>
      <td>115.103</td>
      <td>0</td>
      <td>15</td>
      <td>29.14</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>0</td>
      <td>16300</td>
      <td>65019</td>
      <td>89235.5</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>7</td>
      <td>0</td>
      <td>0</td>
      <td>173.467</td>
      <td>1</td>
      <td>20</td>
      <td>34.8183</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>0</td>
      <td>23300</td>
      <td>91491</td>
      <td>119832</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>13</td>
      <td>0</td>
      <td>0</td>
      <td>231.575</td>
      <td>2</td>
      <td>26</td>
      <td>39.0031</td>
    </tr>
    <tr>
      <th>max</th>
      <td>1</td>
      <td>89900</td>
      <td>399550</td>
      <td>855909</td>
      <td>HomeImp</td>
      <td>Self</td>
      <td>41</td>
      <td>10</td>
      <td>15</td>
      <td>1168.23</td>
      <td>17</td>
      <td>71</td>
      <td>203.312</td>
    </tr>
  </tbody>
</table>
</div>



### Data Visualisation
+ Standard Python packages can be used to visualize data.
+ For example matplotlib functionality combined with SWAT methods can be used.


```python
castbl.hist(figsize=(10,10))
plt.show()
```


![png](output_29_0.png)


### Data Manipulation
+ Python libraries like Pandas can be used.


```python
#mean debt value by reason type
castbl.groupby('REASON').VALUE.mean()
```




    REASON
                95919.280172
    DebtCon    102172.956197
    HomeImp    101675.094662
    Name: VALUE, dtype: float64



### Model Building
+ You can use SWAT to build models like decision trees, regression etc.
+ Python packages like SciKit-Learn are also available.
