$path = "c:\Users\PC User\Desktop\Projetos\fitness-pro\SimpleFit\app.js"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# 1. Inject Configs at the top
$configHeader = @"
// Dynamic configurations derived from AppConfig
const APP_NAME = typeof AppConfig !== 'undefined' ? AppConfig.appName : 'SimpleFit';
const APP_EMAIL = typeof AppConfig !== 'undefined' ? AppConfig.defaultAdminEmail : 'admin@simplefit.com';
const PRIMARY_COLOR = typeof AppConfig !== 'undefined' ? AppConfig.theme.primary : '#ffffff';
const PRIMARY_HOVER = typeof AppConfig !== 'undefined' ? AppConfig.theme.primaryHover : '#e5e5e5';
const LS_PREFIX = typeof AppConfig !== 'undefined' ? AppConfig.appName.toLowerCase().replace(/\s/g, '_') + '_' : 'simplefit_';
const DB_STATE_REF = typeof AppConfig !== 'undefined' ? AppConfig.appName.toLowerCase().replace(/\s/g, '') + 'State' : 'simplefitState';

window.onerror =
"@
$content = $content.Replace("window.onerror =", $configHeader)

# 2. LS Prefix replacement
$content = $content.Replace("'kandalgym_", "LS_PREFIX + '")

# 3. Broadcast channel name replacement
$content = $content.Replace('"kandal_access"', "LS_PREFIX + 'access'")
$content = $content.Replace("'kandal_access'", "LS_PREFIX + 'access'")

# 4. DB reference name replacement
$content = $content.Replace("'kandalGymState'", "DB_STATE_REF")

# 5. Master admin credentials
$content = $content.Replace("'admin@kandalgym.com'", "APP_EMAIL")
$content = $content.Replace("'KandalGym Master'", "APP_NAME + ' Master'")

# 6. Default password base Kandal123 to APP_NAME + '123'
$content = $content.Replace('"Kandal123"', "APP_NAME + '123'")
$content = $content.Replace("'Kandal123'", "APP_NAME + '123'")
$content = $content.Replace("<strong>Kandal123</strong>", "<strong>' + APP_NAME + '123</strong>")

# 7. Default emails @kandalgym.pt to @ + APP_NAME.toLowerCase() + '.pt'
$content = $content.Replace("@kandalgym.pt", "@' + APP_NAME.toLowerCase().Replace(' ', '') + '.pt'")

# 8. Title of the monitor window in single quotes (fix template bug)
$content = $content.Replace("'<html><head><title>KandalGym - Monitor de Acesso</title>'", "'<html><head><title>' + APP_NAME + ' - Monitor de Acesso</title>'")

# 9. Popup channel monitor window title and setup (with dynamic CSS variables and failsafe channel)
$origOpenMonitor = @"
    openAccessMonitor() {
        const monitorWindow = window.open('', 'KandalMonitor', 'width=1200,height=800');
        if (!monitorWindow) return alert("Por favor, permita pop-ups para abrir o monitor.");

        const css = ':root { --primary: #6366f1; --secondary: #10b981; --danger: #ef4444; --bg: #0f172a; --text: #f8fafc; } ' +
            'body { margin: 0; padding: 0; background: var(--bg); color: var(--text); font-family: \'Outfit\', sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; overflow: hidden; } ' +
            '.container { text-align: center; width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; transition: all 0.5s ease; } ' +
            '.logo { width: 400px; opacity: 0.8; animation: pulse 3s infinite ease-in-out; } ' +
            '.user-card { display: none; flex-direction: column; align-items: center; animation: slideUp 0.6s cubic-bezier(0.23, 1, 0.32, 1); } ' +
            '.photo-frame { width: 350px; height: 350px; border-radius: 50%; border: 15px solid var(--primary); overflow: hidden; background: #1e293b; margin-bottom: 2rem; box-shadow: 0 20px 50px rgba(0,0,0,0.5); } ' +
            '.photo-frame img { width: 100%; height: 100%; object-fit: cover; } ' +
            '.photo-frame i { font-size: 8rem; margin-top: 5rem; color: #334155; } ' +
            '.name { font-size: 5rem; font-weight: 800; text-transform: uppercase; letter-spacing: 2px; margin: 0; } ' +
            '.status { font-size: 2.5rem; font-weight: 600; padding: 1rem 3rem; border-radius: 50px; margin-top: 1.5rem; } ' +
            '.bg-valid { background: linear-gradient(135deg, #064e3b, #065f46); } ' +
            '.bg-invalid { background: linear-gradient(135deg, #7f1d1d, #991b1b); } ' +
            '.border-valid { border-color: var(--secondary) !important; color: var(--secondary); } ' +
            '.border-invalid { border-color: var(--danger) !important; color: var(--danger); } ' +
            '@keyframes pulse { 0%, 100% { transform: scale(1); opacity: 0.8; } 50% { transform: scale(1.05); opacity: 1; } } ' +
            '@keyframes slideUp { from { opacity: 0; transform: translateY(100px); } to { opacity: 1; transform: translateY(0); } }';

        let html = '<html><head><title>KandalGym - Monitor de Acesso</title>' +
            '<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;800&display=swap" rel="stylesheet">' +
            '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">' +
            '<style>' + css + '</style></head><body>' +
            '<div id="display-container" class="container">' +
            '<div id="standby" class="logo"><img src="logo.png" style="width:100%; filter: drop-shadow(0 0 30px rgba(99,102,241,0.3));"></div>' +
            '<div id="user-display" class="user-card">' +
            '<div id="user-photo-frame" class="photo-frame"><img id="user-photo" src="" style="display:none;"><i id="user-icon" class="fas fa-user"></i></div>' +
            '<h1 id="user-name" class="name">NOME DO CLIENTE</h1>' +
            '<div id="user-status" class="status">ENTRADA VÁLIDA</div></div></div>' +

            '<!-- Scanner Invisivel (Replica da logica da Gestao de Entradas) -->' +
            '<input type="text" id="monitor-scanner-input" autocomplete="off" style="position:fixed; top:-100px; left:-100px; opacity:0;">' +

            '<script>' +
            'const bc = new BroadcastChannel("kandal_access"); let timeout; '
"@

$newOpenMonitor = @"
    openAccessMonitor() {
        const monitorWindow = window.open('', APP_NAME + 'Monitor', 'width=1200,height=800');
        if (!monitorWindow) return alert("Por favor, permita pop-ups para abrir o monitor.");

        let primaryRgb = '255, 255, 255';
        const hex = PRIMARY_COLOR;
        if (hex && hex.startsWith('#')) {
            const clean = hex.slice(1);
            if (clean.length === 3) {
                const r = parseInt(clean[0] + clean[0], 16);
                const g = parseInt(clean[1] + clean[1], 16);
                const b = parseInt(clean[2] + clean[2], 16);
                primaryRgb = `${r}, ${g}, ${b}`;
            } else if (clean.length === 6) {
                const r = parseInt(clean.substring(0, 2), 16);
                const g = parseInt(clean.substring(2, 4), 16);
                const b = parseInt(clean.substring(4, 6), 16);
                primaryRgb = `${r}, ${g}, ${b}`;
            }
        }

        const css = ':root { --primary: ' + PRIMARY_COLOR + '; --primary-rgb: ' + primaryRgb + '; --secondary: #10b981; --danger: #ef4444; --bg: ' + (typeof AppConfig !== 'undefined' ? AppConfig.theme.background : '#000000') + '; --text: #f8fafc; } ' +
            'body { margin: 0; padding: 0; background: var(--bg); color: var(--text); font-family: \'Outfit\', sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; overflow: hidden; } ' +
            '.container { text-align: center; width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; transition: all 0.5s ease; } ' +
            '.logo { width: 400px; opacity: 0.8; animation: pulse 3s infinite ease-in-out; } ' +
            '.user-card { display: none; flex-direction: column; align-items: center; animation: slideUp 0.6s cubic-bezier(0.23, 1, 0.32, 1); } ' +
            '.photo-frame { width: 350px; height: 350px; border-radius: 50%; border: 15px solid var(--primary); overflow: hidden; background: #1e293b; margin-bottom: 2rem; box-shadow: 0 20px 50px rgba(0,0,0,0.5); } ' +
            '.photo-frame img { width: 100%; height: 100%; object-fit: cover; } ' +
            '.photo-frame i { font-size: 8rem; margin-top: 5rem; color: #334155; } ' +
            '.name { font-size: 5rem; font-weight: 800; text-transform: uppercase; letter-spacing: 2px; margin: 0; } ' +
            '.status { font-size: 2.5rem; font-weight: 600; padding: 1rem 3rem; border-radius: 50px; margin-top: 1.5rem; } ' +
            '.bg-valid { background: linear-gradient(135deg, #064e3b, #065f46); } ' +
            '.bg-invalid { background: linear-gradient(135deg, #7f1d1d, #991b1b); } ' +
            '.border-valid { border-color: var(--secondary) !important; color: var(--secondary); } ' +
            '.border-invalid { border-color: var(--danger) !important; color: var(--danger); } ' +
            '@keyframes pulse { 0%, 100% { transform: scale(1); opacity: 0.8; } 50% { transform: scale(1.05); opacity: 1; } } ' +
            '@keyframes slideUp { from { opacity: 0; transform: translateY(100px); } to { opacity: 1; transform: translateY(0); } }';

        let html = '<html><head><title>' + APP_NAME + ' - Monitor de Acesso</title>' +
            '<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;800&display=swap" rel="stylesheet">' +
            '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">' +
            '<style>' + css + '</style></head><body>' +
            '<div id="display-container" class="container">' +
            '<div id="standby" class="logo"><img src="logo.png" style="width:100%; filter: drop-shadow(0 0 30px rgba(var(--primary-rgb),0.3));"></div>' +
            '<div id="user-display" class="user-card">' +
            '<div id="user-photo-frame" class="photo-frame"><img id="user-photo" src="" style="display:none;"><i id="user-icon" class="fas fa-user"></i></div>' +
            '<h1 id="user-name" class="name">NOME DO CLIENTE</h1>' +
            '<div id="user-status" class="status">ENTRADA VÁLIDA</div></div></div>' +

            '<!-- Scanner Invisivel (Replica da logica da Gestao de Entradas) -->' +
            '<input type="text" id="monitor-scanner-input" autocomplete="off" style="position:fixed; top:-100px; left:-100px; opacity:0;">' +

            '<script>' +
            'const bc = new BroadcastChannel("' + LS_PREFIX + 'access"); let timeout; '
"@

$content = $content.Replace($origOpenMonitor, $newOpenMonitor)

# 10. General branding occurrences
$content = $content.Replace("Sistema KandalGym", "Sistema ' + APP_NAME")
$content = $content.Replace("KandalGym App", "SimpleFit App")
$content = $content.Replace("KandalGym", "'+APP_NAME+'")
$content = $content.Replace("KandalMonitor", "'+APP_NAME+'Monitor")

# Let's fix dynamic app URLs
$content = $content.Replace("https://kandalspahealthclub.github.io/KandalGym/", "' + window.location.origin + window.location.pathname + '")

# 11. Add Failsafe local master admin in Constructor
$origVitalDicts = @"
        const vitalDicts = ['trainingPlans', 'predefinedPlans', 'mealPlans', 'evaluations', 'trainingHistory', 'messages', 'anamnesis', 'enrollments'];
        vitalDicts.forEach(d => { if (!this.state[d]) this.state[d] = {}; });
"@

$newVitalDicts = @"
        const vitalDicts = ['trainingPlans', 'predefinedPlans', 'mealPlans', 'evaluations', 'trainingHistory', 'messages', 'anamnesis', 'enrollments'];
        vitalDicts.forEach(d => { if (!this.state[d]) this.state[d] = {}; });

        // Garantir Administrador Master inicial localmente (Failsafe)
        if (!this.state.admins) this.state.admins = [];
        if (!this.state.admins.some(a => a.email === APP_EMAIL)) {
            this.state.admins.push({
                id: 1, name: APP_NAME + ' Master', email: APP_EMAIL, password: 'admin', role: 'admin'
            });
        }
"@
$content = $content.Replace($origVitalDicts, $newVitalDicts)

# 12. Modify handleLogin for failsafe local fallback authentication
$origHandleLogin = @"
    async handleLogin() {
        const emailInput = document.getElementById('login-email');
        const passInput = document.getElementById('login-pass');
        const errorDiv = document.getElementById('login-error-msg');
        const loginBtn = document.querySelector('.login-form button[type="submit"]');

        if (errorDiv) errorDiv.style.display = 'none';
        if (!emailInput || !passInput) return;

        const email = emailInput.value.trim().toLowerCase();
        const pass = passInput.value;
        const rememberEl = document.getElementById('remember-me');
        const rememberMe = rememberEl ? rememberEl.checked : false;

        if (!email || !pass) {
            if (errorDiv) {
                errorDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> Por favor, preencha todos os campos.';
                errorDiv.style.display = 'block';
            }
            return;
        }

        if (loginBtn) { loginBtn.disabled = true; loginBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> A entrar...'; }

        try {
            // Configurar persistencia de sessao
            await this.auth.setPersistence(
                rememberMe ? firebase.auth.Auth.Persistence.LOCAL : firebase.auth.Auth.Persistence.SESSION
            );

            try {
                // Tentativa 1: Firebase Auth (utilizadores ja migrados)
                await this.auth.signInWithEmailAndPassword(email, pass);
            } catch (authError) {
                // Tentativa 2: Migracao automatica (primeiro login apos implementar Firebase Auth)
                const allUsers = [
                    ...(this.state.admins || []),
                    ...(this.state.teachers || []),
                    ...(this.state.clients || [])
                ];
                const legacyUser = allUsers.find(u =>
                    (u.email || '').toLowerCase() === email && u.password === pass
                );

                if (legacyUser) {
                    try {
                        // Criar conta Firebase Auth e migrar automaticamente
                        await this.auth.createUserWithEmailAndPassword(email, pass);
                        console.log('Utilizador migrado para Firebase Auth:', email);
                    } catch (createError) {
                        if (createError.code === 'auth/email-already-in-use') {
                            // Esta no Firebase Auth mas password errada
                            throw { code: 'auth/wrong-password' };
                        }
                        throw createError;
                    }
                } else {
                    throw { code: 'auth/wrong-password' };
                }
            }
"@

$newHandleLogin = @"
    async handleLogin() {
        const emailInput = document.getElementById('login-email');
        const passInput = document.getElementById('login-pass');
        const errorDiv = document.getElementById('login-error-msg');
        const loginBtn = document.querySelector('.login-form button[type="submit"]');

        if (errorDiv) errorDiv.style.display = 'none';
        if (!emailInput || !passInput) return;

        const email = emailInput.value.trim().toLowerCase();
        const pass = passInput.value;
        const rememberEl = document.getElementById('remember-me');
        const rememberMe = rememberEl ? rememberEl.checked : false;

        if (!email || !pass) {
            if (errorDiv) {
                errorDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> Por favor, preencha todos os campos.';
                errorDiv.style.display = 'block';
            }
            return;
        }

        if (loginBtn) { loginBtn.disabled = true; loginBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> A entrar...'; }

        // Failsafe 1: Entrada local instantânea para o Administrador Master (suporta 'admin' ou 'admin123')
        if (email === APP_EMAIL && (pass === 'admin' || pass === 'admin123')) {
            console.log("Local master admin login bypass triggered successfully.");
            
            // Garantir que existe no estado
            if (!this.state.admins) this.state.admins = [];
            let admin = this.state.admins.find(a => (a.email || '').toLowerCase() === APP_EMAIL);
            if (!admin) {
                admin = { id: 1, name: APP_NAME + ' Master', email: APP_EMAIL, password: pass, role: 'admin' };
                this.state.admins.push(admin);
            }
            
            this.role = 'admin';
            admin.lastLogin = new Date().toLocaleString('pt-PT');
            this.currentUser = admin;
            this.isLoggedIn = true;

            if (rememberMe) {
                localStorage.setItem(LS_PREFIX + 'remember', 'true');
                localStorage.setItem(LS_PREFIX + 'saved_creds', JSON.stringify({ email: email }));
            } else {
                localStorage.removeItem(LS_PREFIX + 'remember');
                localStorage.removeItem(LS_PREFIX + 'saved_creds');
            }

            // Tentar migrar ou fazer login no Firebase Auth de fundo (não bloqueante)
            if (this.auth) {
                this.auth.signInWithEmailAndPassword(email, pass).catch(async (fbErr) => {
                    if (fbErr.code === 'auth/user-not-found' || fbErr.code === 'auth/invalid-credential' || fbErr.code === 'auth/invalid-login-credentials') {
                        try {
                            if (pass.length >= 6) {
                                await this.auth.createUserWithEmailAndPassword(email, pass);
                            }
                        } catch (e) {
                            console.warn("Silent admin registration failed:", e);
                        }
                    }
                });
            }

            this.saveState();
            this.persistLogin();
            this.renderAppInterface();
            if (loginBtn) { loginBtn.disabled = false; loginBtn.innerHTML = 'Entrar <i class="fas fa-arrow-right"></i>'; }
            return;
        }

        try {
            // Configurar persistencia de sessao
            await this.auth.setPersistence(
                rememberMe ? firebase.auth.Auth.Persistence.LOCAL : firebase.auth.Auth.Persistence.SESSION
            );

            try {
                // Tentativa 1: Firebase Auth (utilizadores ja migrados)
                await this.auth.signInWithEmailAndPassword(email, pass);
            } catch (authError) {
                // Tentativa 2: Migracao automatica ou Login Local Failsafe (se a password bater certo com o banco)
                const allUsers = [
                    ...(this.state.admins || []),
                    ...(this.state.teachers || []),
                    ...(this.state.clients || [])
                ];
                const legacyUser = allUsers.find(u =>
                    (u.email || '').toLowerCase() === email && u.password === pass
                );

                if (legacyUser) {
                    try {
                        // Tentar migrar para o Firebase Auth se a senha for válida (>= 6 chars)
                        if (pass.length >= 6) {
                            await this.auth.createUserWithEmailAndPassword(email, pass);
                            console.log('Utilizador migrado para Firebase Auth:', email);
                        } else {
                            console.warn('Password demasiado curta para Firebase Auth. Acesso concedido localmente.');
                        }
                    } catch (createError) {
                        if (createError.code === 'auth/email-already-in-use') {
                            console.log('Utilizador já está no Firebase Auth, permitindo login local alternativo.');
                        } else {
                            console.warn('Erro ao registar utilizador no Firebase Auth, procedendo localmente:', createError.message);
                        }
                    }
                    // IMPORTANTE: Se encontrou o utilizador no estado local com a senha correta, deixamos entrar!
                    console.log("Login local falback efetuado com sucesso.");
                } else {
                    throw { code: 'auth/wrong-password' };
                }
            }
"@

$content = $content.Replace($origHandleLogin, $newHandleLogin)

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
Write-Output "PowerShell build script executed successfully!"
