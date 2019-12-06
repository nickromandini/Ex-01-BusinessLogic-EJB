package it.distributedsystems.model.interceptors;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.annotation.Resource;
import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;
import javax.jms.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class OperationLogger {

    @Resource(mappedName="java:comp/DefaultJMSConnectionFactory")
    private ConnectionFactory connectionFactory;

    @Resource(mappedName="java:/jms/queue/Log")
    private Queue queue;

    private Connection connection;
    private Session session;
    private MessageProducer producer;


    private void init(){
        try {
            connection = connectionFactory.createConnection();
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            producer = session.createProducer(queue);
        } catch (JMSException e ){
            e.printStackTrace();
        }
    }

    @AroundInvoke
    public Object logOperation(final InvocationContext context) throws Exception{
        Object res = context.proceed();
        if(session == null || producer == null)
            init();
        StringBuilder msg = new StringBuilder();
        LocalDateTime date = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");
        msg.append("[LOG " + date.format(formatter) +"] ");
        msg.append("Invoked operation " + context.getMethod().getName() + " on target " + context.getTarget().getClass().getName());
        TextMessage message = session.createTextMessage(msg.toString());
        producer.send(message);
        return res;
    }

    @PreDestroy
    public void clean(){
        try {
            session.close();
            connection.close();
        } catch (JMSException e){
            e.printStackTrace();
        }
    }
}
