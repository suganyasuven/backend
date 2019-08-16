Code-Coverage-Dashboard - Ballerina backend

This will work as the backend to the Code Coverage Dashboard which retrieve the coverage summary from the database.

- Add ballerina.conf to engineering-mgt/code-coverage-dashboard/backend/src

  Sample ballerina.conf :
```
  DB_HOST = "localhost"
  DB_PORT = "3306"
  DB_NAME = "WSO2_PRODUCT_COMPONENT"
  USERNAME = "root"
  PASSWORD = "root"
  
 SERVER_URL = ""http://localhost:3000"
"
```

- Navigate to engineering-mgt/code-coverage-dashboard/backend/src and run `ballerina build wso2` then `ballerina run -c ballerina.conf target/wso2.balx` inorder to start the ballerina service