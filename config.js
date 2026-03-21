// System Configuration - My Fitness App Base
// Este ficheiro permite gerir todas as configurações globais da aplicação de forma fácil.
const AppConfig = {
    // Configurações Gerais
    appName: "Fitness App",
    appTitle: "Fitness App - Personal Trainer & Planeamento",
    logoPath: "logo.png", // Nome do seu ficheiro da logo
    heroPath: "hero1.png", // Imagem de fundo principal
    defaultAdminEmail: "admin@fitnessapp.com",
    
    // Configurações de Cores
    // Para alterar o estilo da App, modifique aqui. (Pode usar Hex ou RGBA)
    theme: {
        primary: "#911B2B",       // Cor principal (ex: botões, ícones)
        primaryHover: "#751421",  // Cor principal ao passar o rato
        background: "#0f1218"     // Cor de fundo padrão
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
