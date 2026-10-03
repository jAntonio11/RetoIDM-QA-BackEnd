package serverest;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Ejecuta toda la suite (mvn test). Los escenarios auxiliares marcados con @ignore se omiten.
 * El número de hilos se puede ajustar con -Dhilos=3
 */
class ServeRestTest {

    @Test
    void ejecutarSuiteCompleta() {
        int hilos = Integer.getInteger("hilos", 1);
        Results resultados = Runner.path("classpath:serverest")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(hilos);
        assertEquals(0, resultados.getFailCount(), resultados.getErrorMessages());
    }
}
