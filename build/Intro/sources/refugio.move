module refugio::refugio;

use std::string::String;
use sui::object::UID;
use sui::transfer;
use sui::tx_context::TxContext;
use sui::vec_map::{Self, VecMap};

// Códigos de error personalizados
const ID_YA_EXISTE: u64 = 1;
const ID_NO_EXISTE: u64 = 2;

// Estructura principal Refugio, con key para que sea un objeto global
public struct Refugio has key, store {
    id: UID,
    nombre: String,
    contacto: String,
    animales: VecMap<u8, Animal>,
}

// Estructura Animal con copy, drop, store porque es un dato que estará dentro de Refugio
public struct Animal has copy, drop, store {
    nombre: String,
    especie: String,
    adoptado: bool,
}

// Función para crear un nuevo refugio
public fun crear_refugio(nombre: String, contacto: String, ctx: &mut TxContext) {
    let refugio = Refugio {
        id: object::new(ctx),
        nombre,
        contacto,
        animales: vec_map::empty(),
    };

    // Transferimos la propiedad del refugio al creador de la transacción
    transfer::transfer(refugio, tx_context::sender(ctx));
}

// Función para registrar un animal en el refugio
public fun registrar_animal(refugio: &mut Refugio, id_animal: u8, nombre: String, especie: String) {
    // Verificamos que el ID no exista ya para evitar duplicados
    assert!(!refugio.animales.contains(&id_animal), ID_YA_EXISTE);

    let animal = Animal {
        nombre,
        especie,
        adoptado: false,
    };

    refugio.animales.insert(id_animal, animal);
}

// Función para marcar un animal como adoptado
public fun marcar_adoptado(refugio: &mut Refugio, id_animal: u8) {
    // Verificamos que el animal exista
    assert!(refugio.animales.contains(&id_animal), ID_NO_EXISTE);

    let animal_ref = refugio.animales.get_mut(&id_animal);
    animal_ref.adoptado = true;
}

// Función para eliminar un animal del refugio
public fun eliminar_animal(refugio: &mut Refugio, id_animal: u8) {
    // Verificamos que el animal exista
    assert!(refugio.animales.contains(&id_animal), ID_NO_EXISTE);

    refugio.animales.remove(&id_animal);
}

// Función para eliminar el refugio completo
public fun eliminar_refugio(refugio: Refugio) {
    let Refugio { id, nombre: _, contacto: _, animales: _ } = refugio;
    id.delete();
}
