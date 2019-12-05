<%@ page session ="true"%>
<%@ page import="java.util.*" %>
<%@ page import="it.distributedsystems.model.dao.*" %>


<%!
	String printTableRow(Product product, String url) {
		StringBuffer html = new StringBuffer();
		html
				.append("<tr>")
				.append("<td>")
				.append(product.getName())
				.append("</td>")

				.append("<td>")
				.append(product.getProductNumber())
				.append("</td>")

				.append("<td>")
				.append( (product.getProducer() == null) ? "n.d." : product.getProducer().getName() )
				.append("</td>");

		html
				.append("</tr>");

		return html.toString();
	}

	String printTableRows(List products, String url) {
		StringBuffer html = new StringBuffer();
		Iterator iterator = products.iterator();
		while ( iterator.hasNext() ) {
			html.append( printTableRow( (Product) iterator.next(), url ) );
		}
		return html.toString();
	}
%>

<html>

	<head>
		<title>HOMEPAGE DISTRIBUTED SYSTEM EJB</title>
	
		<meta http-equiv="Pragma" content="no-cache"/>
		<meta http-equiv="Expires" content="Mon, 01 Jan 1996 23:59:59 GMT"/>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<meta name="Author" content="you">

		<link rel="StyleSheet" href="styles/default.css" type="text/css" media="all" />
	
	</head>
	
	<body>

	<%
		// can't use builtin object 'application' while in a declaration!
		// must be in a scriptlet or expression!
		DAOFactory daoFactory = DAOFactory.getDAOFactory( application.getInitParameter("dao") );
		CustomerDAO customerDAO = daoFactory.getCustomerDAO();
		PurchaseDAO purchaseDAO = daoFactory.getPurchaseDAO();
		ProductDAO productDAO = daoFactory.getProductDAO();
		ProducerDAO producerDAO = daoFactory.getProducerDAO();

		String operation = request.getParameter("operation");
		if ( operation != null && operation.equals("insertCustomer") ) {
			Customer customer = new Customer();
			customer.setName( request.getParameter("name") );
			int id = customerDAO.insertCustomer( customer );
			out.println("<!-- inserted customer '" + customer.getName() + "', with id = '" + id + "' -->");
		}
		else if ( operation != null && operation.equals("insertProducer") ) {
			Producer producer = new Producer();
			producer.setName( request.getParameter("name") );
			int id = producerDAO.insertProducer( producer );
			out.println("<!-- inserted producer '" + producer.getName() + "', with id = '" + id + "' -->");
		}
		else if ( operation != null && operation.equals("insertProduct") ) {
			Product product = new Product();
			product.setName( request.getParameter("name") );
			product.setProductNumber(Integer.parseInt(request.getParameter("number")));

			Producer producer = producerDAO.findProducerByName(request.getParameter("producer"));
			product.setProducer(producer);
			int id = productDAO.insertProduct(product);
			out.println("<!-- inserted product '" + product.getName() + "' with id = '" + id + "' -->");
		} else if(operation != null && operation.equals("insertPurchase") ) {

			Product product = productDAO.findProductByNumber(Integer.parseInt(request.getParameter("product")));
			Customer customer = customerDAO.findCustomerByName(request.getParameter("customer"));
			Purchase purchase = new Purchase();
			purchase.setCustomer(customer);
			Set products = new HashSet<Product>();
			products.add(product);
			purchase.setProducts(products);
			int id = purchaseDAO.insertPurchase(purchase);
			out.println("<!-- inserted purchase '" + purchase.getPurchaseNumber() + "' with id = '" + id + "' -->");
		} else if(operation != null && operation.equals("test") ) {
			out.println(Integer.parseInt(request.getParameter("id")));

			Purchase purchase = purchaseDAO.findPurchaseById(Integer.parseInt(request.getParameter("id")));
			out.println("purch " + purchase.getCustomer().getName());
			out.println("products " + purchase.getProducts().size());
		}

		//Da aggiungere la possibilità di fare un ordine in sessione e di finalizzarla per creare un purchase.
	%>


	<h1>Customer Manager</h1>

	<div>
		<p>Add Customer:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			<input type="hidden" name="operation" value="insertCustomer"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>

	<div>
		<p>Add Producer:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			<input type="hidden" name="operation" value="insertProducer"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>

	<div>
		<p>Add Product:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			Product Number: <input type="text" name="number"/><br/>
			<input type="hidden" name="operation" value="insertProduct"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>
	<%
		List producers = producerDAO.getAllProducers();
		if ( producers.size() > 0 ) {
	%>
	<div>
		<p>Add Product:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			Product Number: <input type="text" name="number"/><br/>
			Producers: <select name="producer">
			<%
				Iterator iterator = producers.iterator();
				while ( iterator.hasNext() ) {
					Producer producer = (Producer) iterator.next();
			%>
			<option value="<%= producer.getName() %>"><%= producer.getName()%></option>
			<%
				}// end while
			%>

			<input type="hidden" name="operation" value="insertProduct"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>
	<%
	}// end if
	else {
	%>
	<div>
		<p>At least one Producer must be present to add a new Product.</p>
	</div>
	<%
		} // end else
	%>
	<%
		List products = productDAO.getAllProducts();
		List customers = customerDAO.getAllCustomers();
		if ( products.size() > 0 && customers.size() > 0) {
	%>
	<div>
		<p>Add Purchase:</p>
		<form>
			Customer: <select name="customer">
				<%
				Iterator iterator = customers.iterator();
				while ( iterator.hasNext() ) {
					Customer customer = (Customer) iterator.next();
			%>
			<option value="<%= customer.getName() %>"><%= customer.getName()%></option>
				<%
				}// end while
			%>
		</select>
			Products: <select name="product">
				<%
				iterator = products.iterator();
				while ( iterator.hasNext() ) {
					Product product = (Product) iterator.next();
			%>
			<option value="<%= product.getProductNumber() %>"><%= product.getProductNumber()%></option>
				<%
				}// end while
			%>
		</select>
			<input type="hidden" name="operation" value="insertPurchase"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>
	<%
	}// end if
	else {
	%>
	<div>
		<p>Not possibile to add a purchase.</p>
	</div>
	<%
		} // end else
	%>
	<div>

	</div>
	<div>
		<p>Products currently in the database:</p>
		<table>
			<tr><th>Name</th><th>ProductNumber</th><th>Publisher</th><th></th></tr>
			<%= printTableRows( productDAO.getAllProducts(), request.getContextPath() ) %>
		</table>
	</div>
	<form>
		<input type="text" name="id"/><br/>
		<input type="hidden" name="operation" value="test"/>
		<input type="submit" name="submit" value="submit"/>
	</form>
	<div>
		<a href="<%= request.getContextPath() %>">Ricarica lo stato iniziale di questa pagina</a>
	</div>

	</body>

</html>