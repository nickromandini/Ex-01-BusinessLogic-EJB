package it.distributedsystems.model.ejb;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.annotation.Resource;
import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.jms.*;

@MessageDriven(
        activationConfig = {
                @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
                @ActivationConfigProperty(propertyName = "destination", propertyValue = "java:/jms/queue/Log")
        })
public class EJB3LoggerMDB implements javax.jms.MessageListener {

    @Resource(mappedName = "java:comp/DefaultJMSConnectionFactory")
    private ConnectionFactory connectionFactory;


    private Connection connection;
    private Session session;

    @PostConstruct
    public void init(){
        try {
            connection = connectionFactory.createConnection();
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        } catch (JMSException e){
            e.printStackTrace();
        }
    }

    public void onMessage(Message message){
        TextMessage msg = null;

        try {
            if (message instanceof TextMessage) {
                msg = (TextMessage) message;
                System.out.println(msg.getText());
            }
        } catch (JMSException e) {
            e.printStackTrace();
        }
    }

    @PreDestroy
    public void clean() {
        try {
            session.close();
            connection.close();
        } catch (JMSException e) {
            e.printStackTrace();
        }
    }

}
