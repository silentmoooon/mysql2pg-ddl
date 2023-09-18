--
-- Table structure for table:pay_details
--
CREATE TABLE pay_details (
    id char(32) NOT NULL,
    reqdatetime char(17) NOT NULL,
    resdatetime char(17) NULL,
    mchid varchar(32) NULL,
    reqsys varchar(4) NOT NULL,
    orderno varchar(32) NULL,
    serial varchar(32) NOT NULL,
    settledate varchar(8) NOT NULL,
    orderdate varchar(8) NULL,
    ordermoney varchar(20) NULL,
    payment varchar(20) NULL,
    resultcode varchar(6) NULL,
    returncode varchar(6) NULL,
    mchrspcode6 varchar(10) NULL,
    rspcode2 varchar(6) NULL,
    payorgrspcode varchar(6) NULL,
    paysys varchar(20) NULL,
    paymenttype varchar(50) NULL,
    activitycode varchar(10) NULL,
    businesstype varchar(2) NULL,
    businessline varchar(20) NULL,
    rcvmchtime varchar(17) NOT NULL,
    rspmchtime varchar(17) NULL,
    reqpaytime varchar(17) NULL,
    rcvpaytime varchar(17) NULL,
    reqmchtime varchar(17) NULL,
    createtime timestamp NOT NULL,
    reserve1 varchar(20) NULL,
    reserve2 varchar(20) NULL,
    reserve3 varchar(20) NULL,
    computerroomip varchar(12) NULL,
    primary key (settledate,id)
);

CREATE UNIQUE INDEX index_rcvmchtime ON pay_details(rcvmchtime);
CREATE INDEX index_settledate ON pay_details(settledate,createtime);
CREATE INDEX index_createtime ON pay_details(createtime);
CREATE INDEX index_reqsys ON pay_details(reqsys);

COMMENT ON COLUMN pay_details.id IS '主键';
COMMENT ON COLUMN pay_details.reqdatetime IS '商户请求时间';
COMMENT ON COLUMN pay_details.resdatetime IS '收到商户结果通知响应时间';
COMMENT ON COLUMN pay_details.mchid IS '统一支付分配的商户号';
COMMENT ON COLUMN pay_details.reqsys IS '发起方系统';
COMMENT ON COLUMN pay_details.orderno IS '商户订单号';
COMMENT ON COLUMN pay_details.serial IS '交易流水';
COMMENT ON COLUMN pay_details.settledate IS '结算日期';
COMMENT ON COLUMN pay_details.orderdate IS '订单日期';
COMMENT ON COLUMN pay_details.ordermoney IS '订单金额';
COMMENT ON COLUMN pay_details.payment IS '支付金额';
COMMENT ON COLUMN pay_details.resultcode IS '业务结果';
COMMENT ON COLUMN pay_details.returncode IS '返回状态码';
COMMENT ON COLUMN pay_details.mchrspcode6 IS '商户的结果通知响应，返回值有可能为success或Fail';
COMMENT ON COLUMN pay_details.rspcode2 IS '同步响应消息到商户';
COMMENT ON COLUMN pay_details.payorgrspcode IS '支付机构应答码';
COMMENT ON COLUMN pay_details.paysys IS '支付对接机构(例如金科CMPOS)';
COMMENT ON COLUMN pay_details.paymenttype IS '支付方式';
COMMENT ON COLUMN pay_details.activitycode IS '交易编码';
COMMENT ON COLUMN pay_details.businesstype IS '交易类型QR:查询、RQ:查询退费、OD:支付、RF:退费';
COMMENT ON COLUMN pay_details.businessline IS '业务线标识,join:聚合支付';
COMMENT ON COLUMN pay_details.rcvmchtime IS '接收到商户请求时间';
COMMENT ON COLUMN pay_details.rspmchtime IS '同步响应商户请求时间';
COMMENT ON COLUMN pay_details.reqpaytime IS '请求支付机构时间';
COMMENT ON COLUMN pay_details.rcvpaytime IS '接收到支付结果通知时间';
COMMENT ON COLUMN pay_details.reqmchtime IS '发送结果通知到商户时间';
COMMENT ON COLUMN pay_details.createtime IS '数据入库时间，默认直接获取数据库时间';
COMMENT ON COLUMN pay_details.reserve1 IS '预留字段';
COMMENT ON COLUMN pay_details.reserve2 IS '预留字段';
COMMENT ON COLUMN pay_details.reserve3 IS '预留字段';
COMMENT ON COLUMN pay_details.computerroomip IS 'ip地址';



--
-- Table structure for table:af_task
--
CREATE TABLE af_task (
    id varchar(64) NOT NULL,
    name varchar(64) NULL,
    flowid varchar(64) NULL,
    flowname varchar(64) NULL,
    processid varchar(64) NULL,
    processname varchar(64) NULL,
    state varchar(20) NULL,
    variables text NULL,
    createtime varchar(30) NULL,
    updatetime varchar(30) NULL,
    finishtime varchar(30) NULL,
    settledate varchar(30) NULL,
    busiline varchar(30) NULL,
    province varchar(30) NULL,
    node varchar(60) NULL,
    message varchar(500) NULL,
    usetime varchar(200) NULL,
    primary key (id)
);

COMMENT ON TABLE af_task IS '任务实例表';



--
-- Table structure for table:bl_0001_acc_ori_cmpay
--
DROP TABLE IF EXISTS bl_0001_acc_ori_cmpay;

CREATE TABLE bl_0001_acc_ori_cmpay (
    id varchar(50) NOT NULL,
    busiline varchar(30) NULL,
    settle_date varchar(30) NOT NULL,
    province varchar(30) NULL,
    json json NULL
)
PARTITION BY RANGE (settle_date) (
PARTITION p20220324 VALUES LESS THAN ('20220325'),
PARTITION p20220325 VALUES LESS THAN ('20220326'),
PARTITION p20220326 VALUES LESS THAN ('20220327'),
PARTITION p20220327 VALUES LESS THAN ('20220328'),
PARTITION p20220328 VALUES LESS THAN ('20220329'),
PARTITION p20220329 VALUES LESS THAN ('20220330'),
PARTITION p20220330 VALUES LESS THAN ('20220331'),
PARTITION p20220331 VALUES LESS THAN ('20220401'),
PARTITION p20220401 VALUES LESS THAN ('20220402'),
PARTITION p20220402 VALUES LESS THAN ('20220403'),
PARTITION p20220403 VALUES LESS THAN ('20220404'),
PARTITION p20220404 VALUES LESS THAN ('20220405'),
PARTITION p20220405 VALUES LESS THAN ('20220406'),
PARTITION p20220406 VALUES LESS THAN ('20220407'),
PARTITION p20220407 VALUES LESS THAN ('20220408'),
PARTITION p20220408 VALUES LESS THAN ('20220409'),
PARTITION p20220409 VALUES LESS THAN ('20220410'),
PARTITION p20220410 VALUES LESS THAN ('20220411'),
PARTITION p20220411 VALUES LESS THAN ('20220412'),
PARTITION p20220412 VALUES LESS THAN ('20220413'),
PARTITION p20220413 VALUES LESS THAN ('20220414'),
PARTITION p20220414 VALUES LESS THAN ('20220415'),
PARTITION p20220415 VALUES LESS THAN ('20220416'),
PARTITION p20220416 VALUES LESS THAN ('20220417')
);

CREATE INDEX index_bl_0001_acc_ori_cmpay_settle_date ON bl_0001_acc_ori_cmpay(settle_date);

COMMENT ON TABLE bl_0001_acc_ori_cmpay IS '和包对账数据表';
COMMENT ON COLUMN bl_0001_acc_ori_cmpay.id IS 'ID';
COMMENT ON COLUMN bl_0001_acc_ori_cmpay.busiline IS '业务线';
COMMENT ON COLUMN bl_0001_acc_ori_cmpay.settle_date IS '账期日';
COMMENT ON COLUMN bl_0001_acc_ori_cmpay.province IS '省编码';
COMMENT ON COLUMN bl_0001_acc_ori_cmpay.json IS 'JSON集';



