<%@ page session ="true"%>
<%@ page import="java.util.*" %>
<%@ page import="it.distributedsystems.model.dao.*" %>
<%@ page import="it.distributedsystems.model.ejb.Cart" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>


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
		ProductDAO productDAO = daoFactory.getProductDAO();
		Cart cart = (Cart)session.getAttribute("cart");
		if(cart == null) {
			InitialContext context = new InitialContext();
			cart = (Cart) context.lookup("java:global/distributed-systems-demo/distributed-systems-demo.war/EJB3Cart!it.distributedsystems.model.ejb.Cart");
			session.setAttribute("cart", cart);
		}
		String operation = request.getParameter("operation");
		if ( operation != null && operation.equals("setCustomer") ) {
			Customer customer = customerDAO.findCustomerByName(request.getParameter("customer"));
			cart.setCustomer(customer);
			out.println("<!-- setted customer " + customer.getName() + " -->");
		} else if (operation != null && operation.equals("addProduct")) {
			Product product = productDAO.findProductById(Integer.parseInt(request.getParameter("product")));
			cart.addProduct(product);
			out.println("<!-- added product " + product.getName()+ " -->");
		} else if (operation != null && operation.equals("removeProduct")) {
			Product product = productDAO.findProductById(Integer.parseInt(request.getParameter("product")));
			cart.removeProduct(product);
			out.println("<!-- removed product " + product.getName()+ " -->");
		} else if (operation != null && operation.equals("finalizePurchase")) {
			String res = cart.finalizePurhcase();
			out.println("<!-- "+res+" -->");
			session.invalidate();
		}

	%>


	<h1>Cart</h1>
	<%
		List products = productDAO.getAllProducts();
		List customers = customerDAO.getAllCustomers();
		Iterator iterator;
		if ( products.size() > 0 && customers.size() > 0) {
	%>
	<div>
		<p>Select Customer:</p>
		<form>
			<select name="customer">
			<%
				iterator = customers.iterator();
				while ( iterator.hasNext() ) {
					Customer customer = (Customer) iterator.next();
			%>
			<option value="<%= customer.getName() %>"><%= customer.getName()%></option>
			<%
				}// end while
			%>
				<input type="hidden" name="operation" value="setCustomer"/>
				<input type="submit" name="submit" value="Set"/>
			</select>
		</form>
		<p>Add Product:</p>
		<form>
			<select name="product">
				<%
					iterator = products.iterator();
					while ( iterator.hasNext() ) {
						Product product = (Product) iterator.next();
						if(product.getPurchase() == null) {
							%>
							<option value="<%= product.getId() %>"><%= product.getName()%></option>
							<%
						}
					}// end while
				%>
				<input type="hidden" name="operation" value="addProduct"/>
				<input type="submit" name="submit" value="Add"/>
			</select>
		</form>
	</div>
	<%
		} else {
			out.println("Ancora nessun customer o prodotto registrato");
		}
	%>

	<% if(operation != null && !operation.equals("finalizePurchase")) { %>
	<div>

		<p>Current purchase information:<br>
			<%
				if(cart.getCustomer() != null) {
					%>
			Customer: <%=cart.getCustomer().getName()%><%
				}
				if(cart.getProducts().size()>0) {
					%><br>Products:<br><%
					iterator = cart.getProducts().iterator();
					while(iterator.hasNext()){
						Product p = (Product) iterator.next();
			%><%=p.getName()%><br><%
					}
				}
			%>
		</p>
		</br>
		<form>
			<input type="hidden" name="operation" value="finalizePurchase" />
			<input type="submit" name="submit" value="Finalize" />
		</form>

	</div>
	<%}%>

	<div>
		<a href="<%= request.getContextPath() %>">Ricarica lo stato iniziale di questa pagina</a><br>
		<a href="admin.jsp">Admin page</a>
	</div>

	</body>

</html>