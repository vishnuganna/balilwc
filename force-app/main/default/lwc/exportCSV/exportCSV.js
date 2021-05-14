const exportDataAsCsv = csvData => {
    if (csvData && csvData.length > 0) {
        let rowEnd = "\n";
        let csvString = "";
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        csvData.forEach(function(record) {
            Object.keys(record).forEach(function(key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);

        // splitting using ','
        csvString += rowData.join(",");
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for (let i = 0; i < csvData.length; i++) {
            let colValue = 0;

            // validating keys in data
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    // Key value
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if (colValue > 0) {
                        csvString += ",";
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = csvData[i][rowKey] === undefined ? "" : csvData[i][rowKey];
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        return csvString;
    }
    return "";
};
export { exportDataAsCsv };