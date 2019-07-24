import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/mysql;
import ballerina/sql;

listener http:Listener httpListener = new(9999);

@http:ServiceConfig {
    basePath: "/code_coverage",
    cors: {
        allowOrigins: [config:getAsString("SERVER_URL")]
    }
}

service CodeCoverageData on httpListener {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/summary"
    }
    resource function getCoverageSummary(http:Caller httpCaller, http:Request request) {
        // Initialize an empty http response message
        http:Response response = new;
        //if (products is json) {
        // Invoke retrieveData function to retrieve data from mysql database
        json codeCoverageData = retrieveCoverageSummary();
        // Send the response back to the client with the code coverage data
        response.setPayload(untaint codeCoverageData);
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
     }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/summary/{date}"
    }
    resource function getCoverageSummaryByDate(http:Caller httpCaller, http:Request request, string date ) {
        // Initialize an empty http response message
        http:Response response = new;
        // Invoke retrieveData function to retrieve data from mysql database
        json codeCoverageDataByDate = retrieveCoverageSummaryByDate(untaint date);
        // Send the response back to the client with the code coverage data
        response.setPayload(untaint codeCoverageDataByDate);
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/last-report-date"
    }
    resource function getLastReportDate(http:Caller httpCaller, http:Request request ) {
        // Initialize an empty http response message
        http:Response response = new;
        // Invoke retrieveData function to retrieve data from mysql database
        json last_coverage_report = retrieveLastReportDate();
        // Send the response back to the client with the code coverage data
        response.setPayload(untaint last_coverage_report);
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
    }
}
