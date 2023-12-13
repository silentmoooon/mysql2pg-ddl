package org.example;

import com.alibaba.druid.sql.ast.SQLExpr;
import com.alibaba.druid.sql.ast.SQLObjectImpl;
import com.alibaba.druid.sql.ast.SQLPartition;
import com.alibaba.druid.sql.ast.SQLPartitionBy;
import com.alibaba.druid.sql.ast.statement.SQLColumnConstraint;
import com.alibaba.druid.sql.ast.statement.SQLColumnDefinition;
import com.alibaba.druid.sql.ast.statement.SQLSelectOrderByItem;
import com.alibaba.druid.sql.dialect.mysql.ast.MySqlKey;
import com.alibaba.druid.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;
import com.alibaba.druid.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

public class ProcessSingleCreateTable {

    static Map<String, String> serialMap = new HashMap<>();

    static {
        serialMap.put("int", "serial");
        serialMap.put("bigint", "bigserial");
        serialMap.put("smallint", "smallserial");
    }

    public static String process(MySqlCreateTableStatement createTable) {


        String tableFullyQualifiedName = createTable.getTableName().toLowerCase();
        List<SQLColumnDefinition> columnDefinitions = createTable.getColumnDefinitions();


        //生成目标sql：注释
        String commentSql = extractColumnCommentSql(tableFullyQualifiedName, createTable.getComment(), columnDefinitions);


        //生成目标sql：第一行的建表语句
        String createTableFirstLine = String.format("CREATE TABLE %s (", tableFullyQualifiedName);


        //生成目标sql：主键
        List<String> primaryKeys = createTable.getPrimaryKeyNames();
        primaryKeys = primaryKeys.stream().map(String::toLowerCase).collect(Collectors.toList());
        String primaryKeyColumnSql = primaryKeys.isEmpty() ? null : "    primary key (" + String.join(",", primaryKeys) + ")";

        //生成目标sql：所有列
        String columnSql = generateOtherColumnSql(columnDefinitions);

        //生成分区信息
        String partitionSql = generatePartitionSql(createTable);
        //生成索引信息
        List<MySqlKey> indexes = createTable.getMysqlKeys().stream()
                .filter((MySqlKey index) -> !Objects.equals("PRIMARY", index.getIndexDefinition().getType()))
                .collect(Collectors.toList());

        String indexSql = generateIndexSql(indexes, tableFullyQualifiedName);

        //生成完整建表语句
        return generateFullSql(tableFullyQualifiedName, createTableFirstLine, primaryKeyColumnSql, columnSql,
                partitionSql, indexSql, commentSql);
    }

    private static String generateIndexSql(List<MySqlKey> indexes, String tableName) {
        if (indexes.isEmpty()) {
            return null;
        }

        StringBuilder sql = new StringBuilder();
        for (MySqlKey index : indexes) {
            sql.append("CREATE ");
            if ("UNIQUE".equals(index.getIndexDefinition().getType())) {
                sql.append("UNIQUE ");
            }
            List<SQLSelectOrderByItem> columns = index.getIndexDefinition().getColumns();
            List<String> columnNames = columns.stream().map(sqlSelectOrderByItem -> sqlSelectOrderByItem.toString().toLowerCase()).collect(Collectors.toList());
            sql.append("INDEX ").append(tableName).append("_").append(index.getIndexDefinition().getName().toString().toLowerCase()).append(" ON ").append(tableName.toLowerCase()).append("(").append(String.join(",", columnNames)).append(");\n");
        }
        return sql.toString();
    }

    private static String generatePartitionSql(MySqlCreateTableStatement createTable) {
        SQLPartitionBy partitioning = createTable.getPartitioning();
        if (partitioning == null) {
            return null;
        }
        String p = partitioning.toString().split("\\n")[0];
        String partitionType = p.substring(0, p.indexOf("("));
        String columnName = p.substring(p.indexOf("(") + 1, p.indexOf(")")).toLowerCase();

        StringBuilder sql = new StringBuilder("PARTITION BY " + partitionType + "(" + columnName + ") (\n");
        List<SQLPartition> partitions = partitioning.getPartitions();
        for (int i = 0; i < partitions.size(); i++) {
            SQLPartition partition = partitions.get(i);
            sql.append("PARTITION ").append(partition.getName()).append(" ").append(partition.getValues().toString());
            if (i == partitions.size() - 1) {
                sql.append("\n");
            } else {
                sql.append(",\n");
            }

        }

        return sql + ")";
    }

    private static String generateFullSql(String tableName, String createTableFirstLine, String primaryKeyColumnSql,
                                          String columnSql,
                                          String partitionSql, String indexSql, String commentSql) {
        StringBuilder builder = new StringBuilder();

        //如果没有drop语句,则在此写建表前注释
        if (!App.map.containsKey(tableName)) {
            builder.append("--\n-- Table structure for table:").append(tableName).append("\n--\n");
        }
        // 建表语句首行
        builder.append(createTableFirstLine)
                .append("\n");

        //列
        builder.append(columnSql);

        //主键
        if (primaryKeyColumnSql != null) {
            builder.append(",\n")
                    .append(primaryKeyColumnSql);
        }
        builder.append("\n)");

        //分区
        if (partitionSql != null) {
            builder.append("\n").append(partitionSql);
        }
        builder.append(";\n\n");

        //索引
        if (indexSql != null) {
            builder.append(indexSql).append("\n");
        }


        // 注释
        if (!StringUtils.isEmpty(commentSql)) {
            builder.append(commentSql).append("\n");
        }

        return builder.toString();
    }

    private static String generateOtherColumnSql(List<SQLColumnDefinition> columnDefinitions) {


        StringBuilder columnSql = new StringBuilder(1024);
        for (int i = 0; i < columnDefinitions.size(); i++) {
            SQLColumnDefinition columnDefinition = columnDefinitions.get(i);
            // 列名
            String columnName = columnDefinition.getColumnName().toLowerCase();

            // 类型
            String dataType = columnDefinition.getDataType().getName();
            String postgreDataType = DataTypeMapping.MYSQL_TYPE_TO_POSTGRE_TYPE.get(dataType);
            if (postgreDataType == null) {

                throw new UnsupportedOperationException("mysql dataType not supported yet. " + dataType);
            }
            // 获取类型后的参数，如varchar(512)中，将获取到512
            List<SQLExpr> argumentsStringList = columnDefinition.getDataType().getArguments();
            String argument = null;
            if (argumentsStringList != null && !argumentsStringList.isEmpty()) {
                if (argumentsStringList.size() == 1) {
                    argument = argumentsStringList.get(0).toString();
                } else if (argumentsStringList.size() == 2) {
                    argument = argumentsStringList.get(0) + "," + argumentsStringList.get(1);
                }
            }
            if (argument != null && !argument.trim().isEmpty()) {
                if (postgreDataType.equalsIgnoreCase("bigint")
                        || postgreDataType.equalsIgnoreCase("smallint")
                        || postgreDataType.equalsIgnoreCase("int")
                ) {
                    postgreDataType = postgreDataType;
                } else {
                    postgreDataType = postgreDataType + "(" + argument + ")";
                }
            }

            // 处理默认值，将mysql中的默认值转为pg中的默认值，如mysql的CURRENT_TIMESTAMP转为
            SQLExpr specs = columnDefinition.getDefaultExpr();

            if (specs != null) {
                String mysqlDefault = specs.toString();
                // 是字符串的情况下，内容可能是数字，也可能不是
                if (mysqlDefault.startsWith("'") && mysqlDefault.endsWith("'")) {
                    mysqlDefault = mysqlDefault.replaceAll("'", "");
                } else {
                    // 不是字符串的话，一般就是mysql中的函数，此时要查找对应的pg函数
                    String postgreDefault = DefaultValueMapping.MYSQL_DEFAULT_TO_POSTGRE_DEFAULT.get(mysqlDefault);
                    if (postgreDefault == null) {
                        throw new UnsupportedOperationException("not supported mysql default:" + mysqlDefault);
                    }

                }
            }
            String targetSpecAboutNull = "NULL";
            List<SQLColumnConstraint> constraints = columnDefinition.getConstraints();
            long notNull = constraints.stream().filter(sqlColumnConstraint -> sqlColumnConstraint.toString().trim().equalsIgnoreCase("NOT NULL")).count();
            if (notNull > 0) {
                targetSpecAboutNull = "NOT NULL";
            }
            String sql = "";

            if (columnDefinition.isAutoIncrement()) {
                sql = columnName + " " + serialMap.get(postgreDataType);
            } else {
                sql = columnName + " " + postgreDataType;
            }
            sql += " " + targetSpecAboutNull;

            columnSql.append("    ").append(sql);
            if (i != columnDefinitions.size() - 1) {
                columnSql.append(",").append("\n");
            }
        }
        return columnSql.toString();
    }


    private static String extractColumnCommentSql(String tableFullyQualifiedName, SQLExpr comment, List<SQLColumnDefinition> columnDefinitions) {
        StringBuilder columnComments = new StringBuilder(1024);

        if (comment != null) {
            columnComments.append(String.format("COMMENT ON TABLE %s IS %s;", tableFullyQualifiedName,
                    comment)).append("\n");
        }

        columnDefinitions
                .forEach((SQLColumnDefinition columnDefinition) -> {
                    SQLExpr columnSpecStrings = columnDefinition.getComment();
                    if (columnSpecStrings != null) {
                        String commentString = columnSpecStrings.toString();

                        String commentSql = genCommentSql(tableFullyQualifiedName, columnDefinition.getColumnName().toLowerCase(), commentString);
                        columnComments.append(commentSql).append("\n");

                    }
                });

        return columnComments.toString();
    }


    private static String genCommentSql(String table, String column, String commentValue) {
        return String.format("COMMENT ON COLUMN %s.%s IS %s;", table, column, commentValue);
    }
}
