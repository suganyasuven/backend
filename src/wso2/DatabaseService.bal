import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/mysql;
import ballerina/sql;


mysql:Client CodeCoverageDB = new({
        host: config:getAsString("DB_HOST"),
        port: config:getAsInt("DB_PORT"),
        name: config:getAsString("DB_NAME"),
        username: config:getAsString("USERNAME"),
        password: config:getAsString("PASSWORD"),
        poolOptions: { maximumPoolSize: 10 },
        dbOptions: { useSSL: false }
    });

function retrieveAllProductNames() returns json {
    var productNames = CodeCoverageDB->select("SELECT DISTINCT p.PRODUCT_ID, p.PRODUCT_NAME, p.PRODUCT_ABBR FROM "
    + "PRODUCT p, PRODUCT_REPOS r WHERE p.PRODUCT_ID = r.PRODUCT_ID AND "
    + "r.BUILD_URL IS NOT NULL ORDER BY p.PRODUCT_ID", ());
    if (productNames is table< record {}>) {
        var productNamesJson = json.convert(productNames);
        if (productNamesJson is json) {
            return productNamesJson;
        } else {
            log:printError("Error occured while converting the retrieved product names to json",
            err = productNamesJson);
        }
    } else {
        log:printError("Error occured while retrieving the product names from Database", err = productNames);
    }
}

function retrieveCoverageSummary() returns json {
    int productIterator = 0;
    json products = retrieveAllProductNames();
    json coverageSummaryData = [];
    while (productIterator < products.length()) {
        int proId = untaint <int>products[productIterator].PRODUCT_ID;
        json daySummaries = [];
        var coverageSummaryByProduct = CodeCoverageDB->select("SELECT * FROM PRODUCT p, CODE_COVERAGE_SUMMARY s WHERE "
        + "p.product_id = s.product_id " + "AND p.product_id = " + proId + " ORDER BY date DESC LIMIT 100", ());
        if (coverageSummaryByProduct is table< record {}>) {
            var coverageSummaryByProductJson = json.convert(coverageSummaryByProduct);
            if (coverageSummaryByProductJson is json) {
                int dayIterator = 0;
                while (dayIterator < coverageSummaryByProductJson.length()) {
                    daySummaries[dayIterator] = {};
                    string date = <string>coverageSummaryByProductJson[dayIterator].DATE;
                    date = date.split(" ")[0];
                    json daySummary = {};
                    daySummary.date = date;
                    daySummary.totalInstructions = coverageSummaryByProductJson[dayIterator].TOTAL_INSTRUCTIONS;
                    daySummary.missedInstructions = coverageSummaryByProductJson[dayIterator].MISSED_INSTRUCTIONS;
                    daySummary.totalBranches = coverageSummaryByProductJson[dayIterator].TOTAL_BRANCHES;
                    daySummary.missedBranches = coverageSummaryByProductJson[dayIterator].MISSED_BRANCHES;
                    daySummary.totalComplexity = coverageSummaryByProductJson[dayIterator].TOTAL_CXTY;
                    daySummary.missedComplexity = coverageSummaryByProductJson[dayIterator].MISSED_CXTY;
                    daySummary.totalLines = coverageSummaryByProductJson[dayIterator].TOTAL_LINES;
                    daySummary.missedLines = coverageSummaryByProductJson[dayIterator].MISSED_LINES;
                    daySummary.totalMethods = coverageSummaryByProductJson[dayIterator].TOTAL_METHODS;
                    daySummary.missedMethods = coverageSummaryByProductJson[dayIterator].MISSED_METHODS;
                    daySummary.totalClasses = coverageSummaryByProductJson[dayIterator].TOTAL_CLASSES;
                    daySummary.missedClasses = coverageSummaryByProductJson[dayIterator].MISSED_CLASSES;
                    daySummaries[dayIterator]={};
                    daySummaries[dayIterator] = daySummary;
                    dayIterator = dayIterator + 1;
                }
            } else {
                log:printError("Error occured while converting the retrieved coverageSummary by product to json",
                                                        err = coverageSummaryByProductJson);
            }
        } else {
            log:printError("Error occured while retrieving the coverage summary from Database",
                       err = coverageSummaryByProduct);
        }
        coverageSummaryData[productIterator] = {};
        coverageSummaryData[productIterator].name = products[productIterator].PRODUCT_NAME;
        coverageSummaryData[productIterator].productSummaryData = daySummaries;
        productIterator = productIterator + 1;
    }
    return coverageSummaryData;

}


function retrieveCoverageSummaryByDate(string date) returns json {
    int productIterator = 0;
    string sumDate = date + "%";
    json products = retrieveAllProductNames();
    json coverageSummaryDataByDate = [];

    while (productIterator < products.length()) {

        int proId = untaint <int>products[productIterator].PRODUCT_ID;
        var coverageSummaryByDate = CodeCoverageDB->select("SELECT * FROM PRODUCT p, CODE_COVERAGE_SUMMARY s "
        + " WHERE p.product_id = s.product_id AND p.product_id =" + proId + " AND s.date LIKE '" + sumDate
        + "%' ORDER BY s.date DESC LIMIT 1", ());

        if (coverageSummaryByDate is table< record {}>) {
            var coverageSummaryByDateJson = json.convert(coverageSummaryByDate);
            if (coverageSummaryByDateJson is json) {
                coverageSummaryDataByDate[productIterator] = {};
                json daySummary = {};
                if (coverageSummaryByDateJson.length() > 0) {
                    daySummary.totalInstructions = coverageSummaryByDateJson[0].TOTAL_INSTRUCTIONS;
                    daySummary.missedInstructions = coverageSummaryByDateJson[0].MISSED_INSTRUCTIONS;
                    daySummary.totalBranches = coverageSummaryByDateJson[0].TOTAL_BRANCHES;
                    daySummary.missedBranches = coverageSummaryByDateJson[0].MISSED_BRANCHES;
                    daySummary.totalComplexity = coverageSummaryByDateJson[0].TOTAL_CXTY;
                    daySummary.missedComplexity = coverageSummaryByDateJson[0].MISSED_CXTY;
                    daySummary.totalLines = coverageSummaryByDateJson[0].TOTAL_LINES;
                    daySummary.missedLines = coverageSummaryByDateJson[0].MISSED_LINES;
                    daySummary.totalMethods = coverageSummaryByDateJson[0].TOTAL_METHODS;
                    daySummary.missedMethods = coverageSummaryByDateJson[0].MISSED_METHODS;
                    daySummary.totalClasses = coverageSummaryByDateJson[0].TOTAL_CLASSES;
                    daySummary.missedClasses = coverageSummaryByDateJson[0].MISSED_CLASSES;
                    coverageSummaryDataByDate[productIterator].date = coverageSummaryByDateJson[0].DATE;
                    coverageSummaryDataByDate[productIterator].builds = coverageSummaryByDateJson[0].BUILDS;
                }
                else {
                    coverageSummaryDataByDate[productIterator].date = "";
                    coverageSummaryDataByDate[productIterator].builds = "";
                }
                coverageSummaryDataByDate[productIterator].name = products[productIterator].PRODUCT_NAME;
                coverageSummaryDataByDate[productIterator].abbr = products[productIterator].PRODUCT_ABBR;
                coverageSummaryDataByDate[productIterator].daySummary = daySummary;

            } else {
                log:printError("Error occured while converting the retrieved coverageSummary by date to json",
                                 err = coverageSummaryByDateJson);
            }
        } else {
            log:printError("Error occured while retrieving the coverage summary by date from Database",
                       err = coverageSummaryByDate);
        }
        productIterator = productIterator + 1;
    }
    return coverageSummaryDataByDate;
}

function retrieveLastReportDate() returns json {
    var lastReportDate = CodeCoverageDB->select("SELECT DISTINCT CAST(DATE AS DATE) AS date FROM CODE_COVERAGE_SUMMARY "
    + "ORDER BY CAST(DATE AS DATE) DESC", ());
    if (lastReportDate is table< record {}>) {
        var lastReportDateJson = json.convert(lastReportDate);
        if (lastReportDateJson is json) {
            return lastReportDateJson;
        } else {
            log:printError("Error occured while converting the retrieved last report date to json",
                                              err = lastReportDateJson);
        }
    } else {
        log:printError("Error occured while retrieving the last report date from Database", err = lastReportDate);
    }
}

