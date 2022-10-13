// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract asignatura{

    string public nombre;
    string public curso;
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
   
    mapping(address => DatosAlumno) public datosAlumno;

    Evaluacion[] public evaluaciones;

    address[] public matriculas;

    enum TipoNota {Empty, Np, Normal}

    struct Nota {
        TipoNota tipo;
        uint calificacion;
    }

    mapping(address => mapping(uint => Nota)) public calificaciones;
    
    constructor(string memory _nombre, string memory _curso){
        require(bytes(_nombre).length != 0, "El nombre no puede estar vacio");
        require(bytes(_curso).length != 0, "El curso no puede estar vacio");

        nombre = _nombre;
        curso = _curso;
        profesor = msg.sender;
    }

    function automatricula(string memory _nombre, string memory _email) soloNoAlumnos public{
        require(bytes(_nombre).length != 0, "El nombre no puede estar vacio");
        require(bytes(_email).length != 0, "El email no puede estar vacio");

        DatosAlumno memory datos = DatosAlumno(_nombre, _email);

        datosAlumno[msg.sender] = datos;
        matriculas.push(msg.sender);
    }
    
    function alumnosMatriculados() public view returns(uint){
        return matriculas.length;
    }

    function califica(address alumno, TipoNota tipo, uint _nota, uint evaluacion) soloProfesor public{
        require(estaMatriculado(alumno), "Solo se pueden calificar a un alumno matriculado.");
        require(evaluacion < evaluaciones.length, "No se puede calificar una evaluacion que no existe.");
        require(_nota <= 1000, "No se puede calificar con una nota superior a la maxima permitida.");

        Nota memory nota = Nota(tipo, _nota);
        calificaciones[alumno][evaluacion] = nota;
    }

    function creaEvaluacion(string memory _nombre, uint _fecha, uint _porcentaje) soloProfesor public {
        require(bytes(_nombre).length != 0, "El nombre no puede estar vacio");

        Evaluacion memory datos = Evaluacion(_nombre, _fecha, _porcentaje);
        evaluaciones.push(datos);        
    }
    
    function quienSoy() soloAlumnos public view returns(string memory _nombre, string memory _email){
        DatosAlumno memory datos = datosAlumno[msg.sender];

        _nombre = datos.nombre;
        _email = datos.email;
    }

    function verNota(uint _calificacion) soloAlumnos public view returns(TipoNota tipo, uint calificacion){
        require(_calificacion < evaluaciones.length, "El indice de la evaluacion no existe.");

        Nota memory datos = calificaciones[msg.sender][_calificacion];
        tipo = datos.tipo;
        calificacion = datos.calificacion;
    }

    function estaMatriculado(address alumno) private view returns (bool) {
        string memory _nombre = datosAlumno[alumno].nombre;

        return bytes(_nombre).length != 0;
    } 

    modifier soloProfesor(){
        require(msg.sender == profesor, "Solo el profesor tiene acceso");
        _;
    }

    modifier soloAlumnos(){
        require(msg.sender != profesor, "Solo los alumnos tienen acceso");
        _;
    }

    modifier soloNoAlumnos() {
        require(!estaMatriculado(msg.sender), "Solo permitido a alumnos no matriculados");
        _;
    }
    
    receive() external payable {
        revert("Este contrato no acepta transacciones de dinero");
    }
}