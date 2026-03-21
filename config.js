// System Configuration - My Fitness App Base
// Este ficheiro permite gerir todas as configurações globais da aplicação de forma fácil.
const AppConfig = {
    // Configurações Gerais
    appName: "SimpleFit",
    appTitle: "SimpleFit - Personal Trainer & Planeamento",
    logoPath: "logo.png", // Imagem do logotipo (guarde a sua imagem aqui com este nome)
    heroPath: "hero1.png", // Imagem de fundo principal
    defaultAdminEmail: "admin@simplefit.com",
    
    // Configurações de Cores (Minimalista Dark para combinar com o Logo)
    theme: {
        primary: "#3f3f46",       // Cinzento escuro para botões/ícones para não chocar com o preto/branco
        primaryHover: "#27272a",  // hover
        background: "#000000"     // Fundo 100% Preto
    },

    // Configuração da Base de Dados (Firebase)
    // Substitua pelas credenciais do seu projeto Firebase gratuito
    firebaseConfig: {
        apiKey: "AIzaSyBuigp3QADQH4OlSxi8KDP_q1q1XX74idg",
        authDomain: "simplefit-97f6d.firebaseapp.com",
        databaseURL: "https://simplefit-97f6d-default-rtdb.europe-west1.firebasedatabase.app", // Verifique se é "europe-west1"
        projectId: "simplefit-97f6d",
        storageBucket: "simplefit-97f6d.firebasestorage.app",
        messagingSenderId: "833583931484",
        appId: "1:833583931484:web:356e08bebbb410b45c8699",
        measurementId: "G-6628X6VC4G",
        serverKey: "YOUR_SERVER_KEY" // ATENÇÃO: chave legada para notificações (Cloud Messaging)
    }
};
