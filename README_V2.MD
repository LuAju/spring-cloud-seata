# 设置seata 服务端
## 修改registry.conf
使用nacos作为注册和配置中心
```
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  type = "nacos"

  nacos {
    serverAddr = "localhost"
    namespace = ""
    cluster = "default"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "nacos"

  nacos {
    serverAddr = "localhost"
    namespace = ""
  }
  consul {
    serverAddr = "127.0.0.1:8500"
  }
  apollo {
    app.id = "seata-server"
    apollo.meta = "http://192.168.1.204:8801"
  }
  zk {
    serverAddr = "127.0.0.1:2181"
    session.timeout = 6000
    connect.timeout = 2000
  }
  etcd3 {
    serverAddr = "http://localhost:2379"
  }
  file {
    name = "file.conf"
  }
}
```
## 修改配置信息
修改文件nacos-config.txt，将原来的服务信息改为这个
```txt
service.vgroup_mapping.seata-account-service=default
service.vgroup_mapping.seata-order-service=default
service.vgroup_mapping.seata-storage-service=default
```
## 启动
配置完，将配置信息到导入到nacos中
在conf下执行脚本
```jshelllanguage
nacos-config.sh 127.0.0.1
```
执行成功后，可以在nacos的配置中心中看到配置数据
### 启动seata服务
在bin目录下启动seata服务。-p是端口号， -m是文件模式
```jshelllanguage
seata-server.bat -p 9000 -m file
```
启动成功后，nacos端可以看到新增了一个seata服务。
## 客户端配置
### nacos配置中心的配置
因为使用nacos做配置，所以需要编写bootstrap文件连接配置中心
```yaml
spring:
  cloud:
    nacos:
      config:
        server-addr: localhost:8848
        namespace: public
        group: SEATA_GROUP
```
### 修改数据源代理
```java
@Configuration
public class DataSourceProxyConfig {

    @Value("${mybatis.mapperLocations}")
    private String mapperLocations;

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource druidDataSource(){
        return new DruidDataSource();
    }

    @Bean
    // 添加primary注解，否则可能无法回滚
    @Primary
    public DataSourceProxy dataSourceProxy(DataSource dataSource) {
        return new DataSourceProxy(dataSource);
    }

    @Bean
    public SqlSessionFactory sqlSessionFactoryBean(DataSourceProxy dataSourceProxy) throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSourceProxy);
        sqlSessionFactoryBean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(mapperLocations));
        sqlSessionFactoryBean.setTransactionFactory(new SpringManagedTransactionFactory());
        return sqlSessionFactoryBean.getObject();
    }

}
```
### 导入seata/conf下的配置文件
同时，将registry.conf文件放到每个服务端额resources文件夹中。因为是nacos方式，已经将配置文件导了进去，所以不用再添加文件。

之后启动服务即可。

# 使用
在开启全局事务的地方加上注解
```java
 @Override
    @GlobalTransactional(name = "fsp-create-order",
            rollbackFor = Exception.class)
    public void create(Order order)
    {
        log.info("----->开始新建订单");
        //1 新建订单
        orderDao.create(order);

        //2 扣减库存
        log.info("----->订单微服务开始调用库存，做扣减Count");
        storageService.decrease(order.getProductId(),order.getCount());
        log.info("----->订单微服务开始调用库存，做扣减end");

        //3 扣减账户
        log.info("----->订单微服务开始调用账户，做扣减Money");
        accountService.decrease(order.getUserId(),order.getMoney());
        log.info("----->订单微服务开始调用账户，做扣减end");

        //4 修改订单状态，从零到1,1代表已经完成
        log.info("----->修改订单状态开始");
        orderDao.update(order.getUserId(),0);
        log.info("----->修改订单状态结束");

        log.info("----->下订单结束了，O(∩_∩)O哈哈~");

    }
```

