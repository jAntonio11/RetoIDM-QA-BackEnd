package serverest.usuarios;

import com.intuit.karate.junit5.Karate;

/**
 * Permite ejecutar los escenarios de usuarios desde el IDE (clic derecho > Run).
 */
class UsuariosRunner {

    @Karate.Test
    Karate todos() {
        return Karate.run().relativeTo(getClass());
    }

    @Karate.Test
    Karate smoke() {
        return Karate.run().tags("@smoke").relativeTo(getClass());
    }
}
