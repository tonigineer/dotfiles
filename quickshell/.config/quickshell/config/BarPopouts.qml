import Quickshell.Io

JsonObject {
    property JsonObject updates: JsonObject {
        property var filterFunction: function isImportant(line) {
            return /^(linux|hypr|nvidia|mesa)/.test(line);
        }
    }
}
