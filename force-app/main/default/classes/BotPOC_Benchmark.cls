/**
 * CLASE DE PRUEBA DE CONCEPTO (POC) - BENCHMARK DE ENRUTAMIENTO NLP
 * Compara dos modelos de Inteligencia Artificial basados en reglas (Prioridad vs Pesos) 
 * para derivar las intenciones de los usuarios en el chat de Nacex.
 */
public class BotPOC_Benchmark {
    
    /**
     * 1. OBJETO DE AUDITORÍA (EXPLAINABLE AI - XAI)
     * En lugar de devolver solo a dónde va el usuario, devolvemos un objeto compuesto.
     * Esto permite imprimir en los logs exactamente POR QUÉ el bot tomó esa decisión,
     * mostrando las palabras clave exactas y las matemáticas aplicadas.
     */
    public class ResultadoEvaluacion {
        public String destinoFinal;
        public String razonamiento;
    }

    /**
     * 2. MOTOR DE PRE-PROCESAMIENTO LINGÜÍSTICO (NORMALIZACIÓN)
     * Su función es "limpiar" la frase del usuario antes de analizarla.
     * Si el usuario dice: "Hola, por favor, necesito enviar un paquete."
     * El sistema lo reduce a: "enviar paquete".
     */
    public static String normalizeAvanzado(String str) {
        if(String.isBlank(str)) return '';
        
        // A. Estandarización: Todo a minúsculas
        str = str.toLowerCase();
        
        // B. Limpieza de Diacríticos: Eliminamos tildes para que "envío" coincida con "envio"
        str = str.replaceAll('[áàäâ]', 'a').replaceAll('[éèëê]', 'e')
                 .replaceAll('[íìïî]', 'i').replaceAll('[óòöô]', 'o')
                 .replaceAll('[úùüû]', 'u');
                 
        // C. Limpieza de símbolos: Nos quedamos solo con texto y números (fuera comas, puntos, etc.)
        str = str.replaceAll('[^a-z0-9\\s]', ' '); 
        
        // D. Filtro de "Stop Words" (Ruido): Eliminamos palabras comunes que no aportan valor de negocio
        // y que podrían generar "falsos positivos" en el motor de IA.
      // Déjalo así:
    String[] stopWords = new String[]{
        ' el ', ' la ', ' los ', ' las ', ' un ', ' una ', ' de ', ' para ', ' por ', 
        ' con ', ' en ', ' a ', ' mi ', ' tu ', ' su ', ' que ', ' como ', ' quiero ', 
        ' necesito ', ' me ', ' te ', ' se ', ' hola ', ' por favor ', ' buenas ', 
        ' tardes ', ' dias ', ' saber ', ' hacer ', ' favor '
    };
        
        str = ' ' + str + ' '; 
        for(String sw : stopWords) { str = str.replaceAll(sw, ' '); }
        
        return str.replaceAll('\\s+', ' ').trim(); // Quitamos espacios dobles sobrantes
    }

    /**
     * 3. GENERADOR DE N-GRAMAS (PRESERVACIÓN DEL CONTEXTO)
     * No podemos buscar solo palabras sueltas. Si el usuario dice "anular recogida", 
     * no significa "anular" por un lado y "recogida" por otro.
     * Este método trocea la frase en combinaciones lógicas de 1, 2 y 3 palabras conjuntas
     * para buscar expresiones complejas en la base de datos.
     */
    public static Set<String> generarNGramas(String text) {
        List<String> words = text.split('\\s+');
        Set<String> combinaciones = new Set<String>();
        for (Integer i = 0; i < words.size(); i++) {
            if (words[i].length() >= 3) combinaciones.add(words[i]); // Token simple (ej: "paquete")
            if (i < words.size() - 1) combinaciones.add(words[i] + ' ' + words[i+1]); // Bigrama (ej: "anular recogida")
            if (i < words.size() - 2) combinaciones.add(words[i] + ' ' + words[i+1] + ' ' + words[i+2]); // Trigrama
        }
        return combinaciones;
    }

    /**
     * 4. ARQUITECTURA DE RENDIMIENTO: CONSTRUCTOR DE CACHÉ
     * Cargar cientos de reglas de la Base de Datos para cada frase consumiría toda la CPU.
     * Este método coge los registros, los fuerza a minúsculas (para evitar fallos case-sensitive),
     * y los indexa en la memoria RAM (Map). 
     * Gracias a esto, la búsqueda de palabras clave tarda literalmente 0 milisegundos.
     */
    public static Map<String, List<Bot_Routing_Rule_POC__c>> construirCache(List<Bot_Routing_Rule_POC__c> diccionario) {
        Map<String, List<Bot_Routing_Rule_POC__c>> cache = new Map<String, List<Bot_Routing_Rule_POC__c>>();
        for(Bot_Routing_Rule_POC__c r : diccionario) {
            if(String.isNotBlank(r.Keyword__c)) {
                String keyLimpia = r.Keyword__c.toLowerCase().trim();
                if(!cache.containsKey(keyLimpia)) { cache.put(keyLimpia, new List<Bot_Routing_Rule_POC__c>()); }
                cache.get(keyLimpia).add(r);
            }
        }
        return cache;
    }

    /**
     * ==============================================================
     * 🥇 MODELO 1: REGLAS ESTRICTAS POR PRIORIDAD
     * Lógica: Se buscan todas las coincidencias. En caso de conflicto,
     * gana siempre el número de prioridad MÁS BAJO (Ej: 1 es más urgente que 10).
     * Ideal para mantener el contexto fuerte de una frase.
     * ==============================================================
     */
    public static ResultadoEvaluacion ejecutarModelo1(String input, Map<String, List<Bot_Routing_Rule_POC__c>> cache) {
        ResultadoEvaluacion res = new ResultadoEvaluacion();
        String text = normalizeAvanzado(input); // 1. Limpiamos la frase
        
        if (String.isBlank(text)) { res.destinoFinal = 'Menu_Principal'; res.razonamiento = 'Frase vacía'; return res; }
        
        Set<String> combinaciones = generarNGramas(text); // 2. Troceamos en N-Gramas
        String bestCategory = 'Menu_Principal';
        Decimal bestPriority = 999; // Empezamos con la peor prioridad posible
        List<String> matchesEncontrados = new List<String>();
        
        // 3. Búsqueda directa en Caché (Buscamos si los trozos existen en nuestro diccionario)
        for(String nGram : combinaciones) {
            if(cache.containsKey(nGram)) {
                for(Bot_Routing_Rule_POC__c r : cache.get(nGram)) {
                    if(r.Priority__c != null) {
                        matchesEncontrados.add('"' + nGram + '" (Prio ' + r.Priority__c + '->' + r.Target_Dialog__c + ')');
                        
                        // Si encontramos una prioridad MEJOR (número menor), actualizamos el ganador
                        if(r.Priority__c < bestPriority) {
                            bestPriority = r.Priority__c;
                            bestCategory = r.Target_Dialog__c;
                        }
                    }
                }
            }
        }
        
        res.destinoFinal = bestCategory;
        res.razonamiento = matchesEncontrados.isEmpty() ? 'Ninguna palabra clave en BD.' : 'LÓGICA: Gana el número de prioridad más bajo | LEYÓ: ' + String.join(matchesEncontrados, ' | ');
        return res;
    }

    /**
     * ==============================================================
     * 🥈 MODELO 2: SISTEMA ACUMULATIVO POR SCORING (PESOS)
     * Lógica: Las palabras clave no desempantan; SUMAN puntos.
     * El modelo va acumulando los puntos asignados a cada categoría.
     * Al final de la frase, la categoría que tenga la suma matemática más alta, gana.
     * ==============================================================
     */
    public static ResultadoEvaluacion ejecutarModelo2(String input, Map<String, List<Bot_Routing_Rule_POC__c>> cache) {
        ResultadoEvaluacion res = new ResultadoEvaluacion();
        String text = normalizeAvanzado(input); // 1. Limpiamos la frase
        
        if (String.isBlank(text)) { res.destinoFinal = 'Menu_Principal'; res.razonamiento = 'Frase vacía'; return res; }
        
        Set<String> combinaciones = generarNGramas(text); // 2. Troceamos
        Map<String, Decimal> scores = new Map<String, Decimal>(); // Pizarra de puntuaciones
        List<String> matchesEncontrados = new List<String>();
        
        // 3. Búsqueda y Suma de Puntos
        for(String nGram : combinaciones) {
            if(cache.containsKey(nGram)) {
                for(Bot_Routing_Rule_POC__c r : cache.get(nGram)) {
                    if(r.Weight__c != null) {
                        matchesEncontrados.add('"' + nGram + '" (Suma +' + r.Weight__c + ' a ' + r.Target_Dialog__c + ')');
                        
                        // Miramos los puntos que tiene esa categoría, y le sumamos los nuevos
                        Decimal current = scores.containsKey(r.Target_Dialog__c) ? scores.get(r.Target_Dialog__c) : 0;
                        scores.put(r.Target_Dialog__c, current + r.Weight__c);
                    }
                }
            }
        }
        
        // 4. Decidir el Ganador
        String bestCategory = 'Menu_Principal';
        Decimal bestScore = 0; 
        
        // Revisamos la pizarra matemática y nos quedamos con la puntuación más alta
        for(String cat : scores.keySet()) {
            if(scores.get(cat) > bestScore) {
                bestScore = scores.get(cat);
                bestCategory = cat;
            }
        }
        
        res.destinoFinal = bestCategory;
        res.razonamiento = matchesEncontrados.isEmpty() ? 'Ninguna palabra clave en BD.' : 'LÓGICA: Suma de pesos totales | LEYÓ: ' + String.join(matchesEncontrados, ' | ') + ' | TOTAL PUNTOS: ' + scores;
        return res;
    }
}