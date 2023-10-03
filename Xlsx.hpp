#include <OpenXLSX.hpp>
#include <iostream>
#include <cmath>
#include <variant>

using namespace std;
using namespace OpenXLSX;

/* -------------------------------------------------------
 * Usage:
 *          Qxls wb = Qxlsx("test.xlsx", "rw");
 *          wb.ws("Sheet1"); // open "Sheet1"
 *          int int_value = wb.value(row, col)
 *          wb.value(row+1, col, "abcdef")
 *          wb.value(row+1, col, 3.1416)
 * -------------------------------------------------------
 */

using Qxlsx = class qxlsx {
    private:
        XLDocument doc;
        XLSheet wks;
        int row, col;
        struct ClassifyType {
            void operator()(int i) const {
                wks.cell(self.row, self.col).value() = i;
            }
            void operator()(float f) const {
                wks.cell(self.row, self.col).value() = f;
            }
            void operator()(string s) const {
                wks.cell(self.row, self.col).value() = s;
            }
        };
    public:
        // mode could be "r", "w", "rw"
        qxlsx(string filename, string mode) {
            doc.create(filename);
        };

        qxlsx()~ {
            if (mode == "w" || mode == "rw") {
                doc.save();
            }
            doc.close();
        };
        
        void ws(string sheetname) {
            wks = doc.workbook().worksheet(sheetname);
        };
        
        XLCellValue value(int row, int col){
            return wks.cell(row, col).value();
        };

        void value(int row, int col, variant<int, float, string> xvalue){
            // wks.cell(row, col).value() = XLCellValue<T>(xvalue);
            self.row = row;
            self.col = col;
            visit(ClassifyType{}, xvalue);
        };


};
