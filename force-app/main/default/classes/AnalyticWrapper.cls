public class AnalyticWrapper{
	public cls_data[] data;
	class cls_data {
		public String elemento_pep;	
		public String denominacion;	
		public String moneda;	
		public String clvper;	
		public Decimal enero;	
		public Decimal febrero;	
		public Decimal marzo;	
		public Decimal abril;	
		public Decimal mayo;	
		public Decimal junio;
        public Decimal julio;	
		public Decimal agosto;	
		public Decimal septiembre;	
		public Decimal octubre;	
		public Decimal noviembre;
        public Decimal diciembre;		
		public String cebe;	
		public String idcliente;	
		public String nifcliente;	
		public String orgventas;	
		public String sector;	
		public String clan;	
		public String idcomercial;	
		public String oficina;	
		public String ve;	
		public String pres;	
		public String cluster;	
		public String tecnologia;
        public String anio;
	}
	public static AnalyticWrapper parse(String json){
		return (AnalyticWrapper) System.JSON.deserialize(json, AnalyticWrapper.class);
	}

}