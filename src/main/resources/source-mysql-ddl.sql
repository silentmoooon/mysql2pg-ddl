-- csv_db.BL_0001_ACC_ORI_CMPAY definition
-- data_store_pay.pay_details definition

CREATE TABLE `pay_details` (
                               `id` char(32) NOT NULL COMMENT '主键',
                               `reqDateTime` char(17) NOT NULL COMMENT '商户请求时间',
                               `resDateTime` char(17) DEFAULT NULL COMMENT '收到商户结果通知响应时间',
                               `mchId` varchar(32) DEFAULT NULL COMMENT '统一支付分配的商户号',
                               `ReqSys` varchar(4) NOT NULL COMMENT '发起方系统',
                               `orderNo` varchar(32) DEFAULT NULL COMMENT '商户订单号',
                               `serial` varchar(32) NOT NULL COMMENT '交易流水',
                               `settleDate` varchar(8) NOT NULL COMMENT '结算日期',
                               `orderDate` varchar(8) DEFAULT NULL COMMENT '订单日期',
                               `orderMoney` varchar(20) DEFAULT NULL COMMENT '订单金额',
                               `payment` varchar(20) DEFAULT NULL COMMENT '支付金额',
                               `resultCode` varchar(6) DEFAULT NULL COMMENT '业务结果',
                               `returnCode` varchar(6) DEFAULT NULL COMMENT '返回状态码',
                               `mchRspCode6` varchar(10) DEFAULT NULL COMMENT '商户的结果通知响应，返回值有可能为success或Fail',
                               `rspCode2` varchar(6) DEFAULT NULL COMMENT '同步响应消息到商户',
                               `payOrgRspCode` varchar(6) DEFAULT NULL COMMENT '支付机构应答码',
                               `paySys` varchar(20) DEFAULT NULL COMMENT '支付对接机构(例如金科CMPOS)',
                               `paymentType` varchar(50) DEFAULT NULL COMMENT '支付方式',
                               `activityCode` varchar(10) DEFAULT NULL COMMENT '交易编码',
                               `businessType` varchar(2) DEFAULT NULL COMMENT '交易类型QR:查询、RQ:查询退费、OD:支付、RF:退费',
                               `businessLine` varchar(20) DEFAULT NULL COMMENT '业务线标识,join:聚合支付',
                               `rcvMchTime` varchar(17) NOT NULL COMMENT '接收到商户请求时间',
                               `rspMchTime` varchar(17) DEFAULT NULL COMMENT '同步响应商户请求时间',
                               `reqPayTime` varchar(17) DEFAULT NULL COMMENT '请求支付机构时间',
                               `rcvPayTime` varchar(17) DEFAULT NULL COMMENT '接收到支付结果通知时间',
                               `reqMchTime` varchar(17) DEFAULT NULL COMMENT '发送结果通知到商户时间',
                               `createTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '数据入库时间，默认直接获取数据库时间',
                               `Reserve1` varchar(20) DEFAULT NULL COMMENT '预留字段',
                               `Reserve2` varchar(20) DEFAULT NULL COMMENT '预留字段',
                               `Reserve3` varchar(20) DEFAULT NULL COMMENT '预留字段',
                               `computerRoomIP` varchar(12) DEFAULT NULL COMMENT 'ip地址',
                               PRIMARY KEY (`settleDate`,`id`),
                              UNIQUE  KEY `index_rcvMchTime` (`rcvMchTime`),
                               KEY `index_settleDate` (`settleDate`,`createTime`),
                               KEY `index_createTime` (`createTime`),
                               KEY `index_ReqSys` (`ReqSys`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC ;
CREATE TABLE `AF_TASK` (
                           `ID` varchar(64) NOT NULL,
                           `NAME` varchar(64) DEFAULT NULL,
                           `FLOWID` varchar(64) DEFAULT NULL,
                           `FLOWNAME` varchar(64) DEFAULT NULL,
                           `PROCESSID` varchar(64) DEFAULT NULL,
                           `PROCESSNAME` varchar(64) DEFAULT NULL,
                           `STATE` varchar(20) DEFAULT NULL,
                           `VARIABLES` text,
                           `CREATETIME` varchar(30) DEFAULT NULL,
                           `UPDATETIME` varchar(30) DEFAULT NULL,
                           `FINISHTIME` varchar(30) DEFAULT NULL,
                           `SETTLEDATE` varchar(30) DEFAULT NULL,
                           `BUSILINE` varchar(30) DEFAULT NULL,
                           `PROVINCE` varchar(30) DEFAULT NULL,
                           `NODE` varchar(60) DEFAULT NULL,
                           `MESSAGE` varchar(500) DEFAULT NULL,
                           `USETIME` varchar(200) DEFAULT NULL,
                           PRIMARY KEY (`ID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='任务实例表';
DROP TABLE IF EXISTS `BL_0001_ACC_ORI_CMPAY`;
CREATE TABLE `BL_0001_ACC_ORI_CMPAY` (
                                         `ID` varchar(50) NOT NULL COMMENT 'ID',
                                         `BUSILINE` varchar(30) DEFAULT NULL COMMENT '业务线',
                                         `SETTLE_DATE` varchar(30) NOT NULL COMMENT '账期日',
                                         `PROVINCE` varchar(30) DEFAULT NULL COMMENT '省编码',
                                         `JSON` json DEFAULT NULL COMMENT 'JSON集',
                                         KEY `INDEX_BL_0001_ACC_ORI_CMPAY_SETTLE_DATE` (`SETTLE_DATE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='和包对账数据表'
/*!50500 PARTITION BY RANGE  COLUMNS(settle_date)
(PARTITION p20220324 VALUES LESS THAN ('20220325') ENGINE = InnoDB,
 PARTITION p20220325 VALUES LESS THAN ('20220326') ENGINE = InnoDB,
 PARTITION p20220326 VALUES LESS THAN ('20220327') ENGINE = InnoDB,
 PARTITION p20220327 VALUES LESS THAN ('20220328') ENGINE = InnoDB,
 PARTITION p20220328 VALUES LESS THAN ('20220329') ENGINE = InnoDB,
 PARTITION p20220329 VALUES LESS THAN ('20220330') ENGINE = InnoDB,
 PARTITION p20220330 VALUES LESS THAN ('20220331') ENGINE = InnoDB,
 PARTITION p20220331 VALUES LESS THAN ('20220401') ENGINE = InnoDB,
 PARTITION p20220401 VALUES LESS THAN ('20220402') ENGINE = InnoDB,
 PARTITION p20220402 VALUES LESS THAN ('20220403') ENGINE = InnoDB,
 PARTITION p20220403 VALUES LESS THAN ('20220404') ENGINE = InnoDB,
 PARTITION p20220404 VALUES LESS THAN ('20220405') ENGINE = InnoDB,
 PARTITION p20220405 VALUES LESS THAN ('20220406') ENGINE = InnoDB,
 PARTITION p20220406 VALUES LESS THAN ('20220407') ENGINE = InnoDB,
 PARTITION p20220407 VALUES LESS THAN ('20220408') ENGINE = InnoDB,
 PARTITION p20220408 VALUES LESS THAN ('20220409') ENGINE = InnoDB,
 PARTITION p20220409 VALUES LESS THAN ('20220410') ENGINE = InnoDB,
 PARTITION p20220410 VALUES LESS THAN ('20220411') ENGINE = InnoDB,
 PARTITION p20220411 VALUES LESS THAN ('20220412') ENGINE = InnoDB,
 PARTITION p20220412 VALUES LESS THAN ('20220413') ENGINE = InnoDB,
 PARTITION p20220413 VALUES LESS THAN ('20220414') ENGINE = InnoDB,
 PARTITION p20220414 VALUES LESS THAN ('20220415') ENGINE = InnoDB,
 PARTITION p20220415 VALUES LESS THAN ('20220416') ENGINE = InnoDB,
 PARTITION p20220416 VALUES LESS THAN ('20220417') ENGINE = InnoDB) */;