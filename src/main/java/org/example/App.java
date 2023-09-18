package org.example;

import com.alibaba.druid.DbType;
import com.alibaba.druid.sql.SQLUtils;
import com.alibaba.druid.sql.ast.SQLStatement;
import com.alibaba.druid.sql.ast.statement.SQLDropTableStatement;
import com.alibaba.druid.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;
import com.alibaba.druid.util.JdbcConstants;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Hello world!
 */
public class App {

    public static Map<String, String> map = new HashMap<>();
    public static void main(String[] args) throws IOException {
        if (args.length != 2) {
            System.out.println("usage: java -jar xxx.jar sourceFile.sql targetFile.sql");
            System.exit(0);
        }
        if (!Files.exists(Paths.get(args[0]))) {
            System.out.println("sourceFile not exists!");
            System.exit(0);

        }
        List<String> strings = Files.readAllLines(Paths.get(args[0]));
        boolean have500500 = false;
        for (int i = 0; i < strings.size(); i++) {
            String s = strings.get(i).trim();
            //对于分区信息,mysql默认会增加/*!50500注释,需要去掉
            if (s.startsWith("/*!50500")) {
                have500500 = true;
                s = s.replace("/*!50500", "").trim();
                strings.set(i, s);
                continue;
            }
            if (have500500 && s.endsWith("*/;")) {
                have500500 = false;
                s = s.replace("*/;", ";");
                strings.set(i, s);
                continue;
            }
        }
        String sqlContent = String.join("\n", strings);
        sqlContent = sqlContent.replaceAll("`", "");

        StringBuilder totalSql = new StringBuilder();
        DbType dbType = JdbcConstants.MYSQL;
        List<SQLStatement> statementList = SQLUtils.parseStatements(sqlContent, dbType);
        for (SQLStatement statement : statementList) {
            if (statement instanceof MySqlCreateTableStatement) {
                String sql = ProcessSingleCreateTable.process((MySqlCreateTableStatement) statement);
                totalSql.append(sql).append("\n\n");
            } else if (statement instanceof SQLDropTableStatement) {
                SQLDropTableStatement dropTableStatement = (SQLDropTableStatement) statement;
                String tableName = dropTableStatement.getName().toString().toLowerCase();
                map.put(tableName, "");
                String sql = ProcessSingleDropTable.process(dropTableStatement);
                totalSql.append(sql).append("\n\n");
            } else {
                throw new UnsupportedOperationException();
            }
        }

        Files.write(Paths.get(args[1]),totalSql.toString().getBytes(StandardCharsets.UTF_8), StandardOpenOption.TRUNCATE_EXISTING,StandardOpenOption.CREATE);

        System.out.println("file saved to :" + args[1]);

    }

}
