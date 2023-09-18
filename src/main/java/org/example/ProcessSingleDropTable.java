package org.example;

import com.alibaba.druid.DbType;
import com.alibaba.druid.sql.ast.statement.SQLDropTableStatement;


public class ProcessSingleDropTable {

    public static String process(SQLDropTableStatement drop) {

        String tableName = drop.getName().toString().toLowerCase();
        boolean ifExists = drop.isIfExists();
        String comment = String.format("--\n-- Table structure for table:%s\n--\n", tableName);
        String dropSql = String.format("DROP TABLE %s %s;", ifExists ? "IF EXISTS" : "", tableName);
        return comment  + dropSql;

    }

}
