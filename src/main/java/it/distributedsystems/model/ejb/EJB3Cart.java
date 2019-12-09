package it.distributedsystems.model.ejb;

import it.distributedsystems.model.dao.Customer;
import it.distributedsystems.model.dao.Product;
import it.distributedsystems.model.dao.Purchase;
import it.distributedsystems.model.dao.PurchaseDAO;

import javax.ejb.EJB;
import javax.ejb.Stateful;
import java.util.HashSet;
import java.util.Set;

@Stateful
public class EJB3Cart implements Cart{

    private Customer customer;
    private Set<Product> products = new HashSet<>();

    @EJB(lookup = "java:global/distributed-systems-demo/distributed-systems-demo.war/EJB3PurchaseDAO!it.distributedsystems.model.dao.PurchaseDAO")
    private PurchaseDAO purchaseDAO;

    public Customer getCustomer(){
        return this.customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Set<Product> getProducts(){
        return this.products;
    }

    public void addProduct(Product product){
        products.add(product);
    }

    public void removeProduct(Product product){
        for(Product p : products) {
            if (p.getId() == product.getId())
                products.remove(p);
        }
    }

    public String finalizePurhcase(){
        if(customer == null || products.size() == 0) {
            return "Can't finalize";
        } else {
            Purchase purchase = new Purchase();
            purchase.setProducts(products);
            purchase.setCustomer(customer);
            int id = purchaseDAO.insertPurchase(purchase);
            return "Purchase finalized with id " + id;
        }
    }

}
