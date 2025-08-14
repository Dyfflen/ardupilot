#include "Copter.h"

#if MODE_AIR_TO_WATER_ENABLED

/*
 * Init e run para o modo AIR_TO_WATER
 * Este modo herda de ModeGuided.
 * Nós apenas chamamos as funções do "pai" (ModeGuided).
 */

// init - chamado na primeira vez que o modo é ativado
bool ModeAirToWater::init(bool ignore_checks)
{
    // Chama o init() do pai (ModeGuided)
    return ModeGuided::init(ignore_checks);
}

// run - chamado a 400hz
void ModeAirToWater::run()
{
    // Chama o run() do pai (ModeGuided)
    // É AQUI QUE ESTAVA O ERRO ANTERIOR
    ModeGuided::run();
}

#endif // MODE_AIR_TO_WATER_ENABLED