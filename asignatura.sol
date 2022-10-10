// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract asignatura{

    string public nombre; // Nombre de la asignatura
    string public curso; // Curso académico
    address public profesor;

    struct DatosAlumno {
        string nombre;
        string email;
    }

    struct Evaluacion {
        string nombre;
        uint fecha;
        uint porcentaje;
    }

    //Construye un map con clave la dirección del
    // usuario y valor la estructura de datos que contiene
    // los datos del alumno. Además le pongo el nombre datosAlumno.
    mapping(address => DatosAlumno) public datosAlumno;

    Evaluacion[] public evaluaciones;
    address[] public matriculas;

    /*
    Se especifica con memory porque estamos indicando que esos argumentos se guardan en
    la zona de memoria que se llama memory.
    Se ponen los nombres con "_" para que no haya conflictos con las de arriba.
    */
    constructor(string memory _nombre, string memory _curso){
        require(bytes(_nombre).length != 0, "El nombre no puede estar vacio");
        require(bytes(_curso).length != 0, "El curso no puede estar vacio");

        nombre = _nombre;
        curso = _curso;
        profesor = msg.sender;
    }

    function automatricula(string memory _nombre, string memory _email) soloAlumnos public{
        require(bytes(_nombre).length != 0, "El nombre no puede estar vacio");
        require(bytes(_email).length != 0, "El email no puede estar vacio");

        DatosAlumno memory datos = DatosAlumno(_nombre, _email);

        datosAlumno[msg.sender] = datos;
        matriculas.push(msg.sender);
    }

    //El view solo dice que es una funcion de lectura, es decir, que solo lee datos
    function alumnosMatriculados() public view returns(uint){
        return matriculas.length;
    }

    function creaEvaluacion(string memory _nombre, uint _fecha, uint _porcentaje) soloProfesor public {
        require(bytes(_nombre).length != 0, "El nombre no puede estar vacio");

        Evaluacion memory datos = Evaluacion(_nombre, _fecha, _porcentaje);
        evaluaciones.push(datos);
    }

    /*
    Si asigno dentro del returns un nombre (en este caso _nombre y _email), no es necesario
    que escriba un return como he hecho en la función automatricula.
    Simplemente devolverá los valores a los que haya asignado a esas variables
    */
    function quienSoy() soloAlumnos public view returns(string memory _nombre, string memory _email){
        DatosAlumno memory datos = datosAlumno[msg.sender];

        _nombre = datos.nombre;
        _email = datos.email;
    }

    modifier soloProfesor(){
        require(msg.sender == profesor, "Solo el profesor tiene acceso");
        _;
    }

    modifier soloAlumnos(){
        require(msg.sender != profesor, "Solo los alumnos tienen acceso");
        _;
    }

    //Toda transsacción a la que se le puede mandar dinero necesita el campo payable
    receive() external payable {
        revert("Este contrato no acepta transacciones de dinero");
    }
}