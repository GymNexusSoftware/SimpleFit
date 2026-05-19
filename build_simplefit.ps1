$path = "c:\Users\PC User\Desktop\Projetos\fitness-pro\SimpleFit\app.js"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# 1. Inject Configs at the top
$configHeader = @'
// Dynamic configurations derived from AppConfig
const APP_NAME = typeof AppConfig !== 'undefined' ? AppConfig.appName : 'SimpleFit';
const APP_EMAIL = typeof AppConfig !== 'undefined' ? AppConfig.defaultAdminEmail : 'admin@simplefit.com';
const PRIMARY_COLOR = typeof AppConfig !== 'undefined' ? AppConfig.theme.primary : '#ffffff';
const PRIMARY_HOVER = typeof AppConfig !== 'undefined' ? AppConfig.theme.primaryHover : '#e5e5e5';
const LS_PREFIX = typeof AppConfig !== 'undefined' ? AppConfig.appName.toLowerCase().replace(/\s/g, '_') + '_' : 'simplefit_';
const DB_STATE_REF = typeof AppConfig !== 'undefined' ? AppConfig.appName.toLowerCase().replace(/\s/g, '') + 'State' : 'simplefitState';

window.onerror =
'@
$content = $content.Replace("window.onerror =", $configHeader)

# 2. Monitor de Acesso - Ajustes Específicos e Seguros de Linha Única
# 2.1 CSS do Monitor de Acesso
$origCssLine = '        const css = '':root { --primary: #6366f1; --secondary: #10b981; --danger: #ef4444; --bg: #0f172a; --text: #f8fafc; } '' +'
$newCssLine = '        let primaryRgb = ''255, 255, 255'';
        const hex = PRIMARY_COLOR;
        if (hex && hex.startsWith(''#'')) {
            const clean = hex.slice(1);
            if (clean.length === 3) {
                primaryRgb = parseInt(clean[0] + clean[0], 16) + '', '' + parseInt(clean[1] + clean[1], 16) + '', '' + parseInt(clean[2] + clean[2], 16);
            } else if (clean.length === 6) {
                primaryRgb = parseInt(clean.substring(0, 2), 16) + '', '' + parseInt(clean.substring(2, 4), 16) + '', '' + parseInt(clean.substring(4, 6), 16);
            }
        }
        const css = '':root { --primary: '' + PRIMARY_COLOR + ''; --primary-rgb: '' + primaryRgb + ''; --secondary: #10b981; --danger: #ef4444; --bg: '' + (typeof AppConfig !== ''undefined'' ? AppConfig.theme.background : ''#000000'') + ''; --text: #f8fafc; } '' +'
$content = $content.Replace($origCssLine, $newCssLine)

# 2.2 Título do HTML no Monitor
$origTitleLine = '        let html = ''<html><head><title>KandalGym - Monitor de Acesso</title>'' +'
$newTitleLine = '        let html = ''<html><head><title>'' + APP_NAME + '' - Monitor de Acesso</title>'' +'
$content = $content.Replace($origTitleLine, $newTitleLine)

# 2.3 Logo Drop Shadow no Monitor
$origLogoLine = '            ''<div id="standby" class="logo"><img src="logo.png" style="width:100%; filter: drop-shadow(0 0 30px rgba(99,102,241,0.3));"></div>'' +'
$newLogoLine = '            ''<div id="standby" class="logo"><img src="logo.png" style="width:100%; filter: drop-shadow(0 0 30px rgba('' + primaryRgb + '',0.3));"></div>'' +'
$content = $content.Replace($origLogoLine, $newLogoLine)

# 2.4 BroadcastChannel específico do Monitor (Substituir ANTES do replace global de kandal_access!)
$origBcLine = '            ''const bc = new BroadcastChannel("kandal_access"); let timeout; '' +'
$newBcLine = '            ''const bc = new BroadcastChannel("'' + LS_PREFIX + ''access"); let timeout; '' +'
$content = $content.Replace($origBcLine, $newBcLine)

# 2.5 Substituição Segura do Nome da Janela do Monitor
$content = $content.Replace("'KandalMonitor'", "APP_NAME + 'Monitor'")

# 3. Substituições de Template Strings de Mensagens, Impressão e Emails (Evita ' + APP_NAME + ' literal e previne SyntaxError)
# 3.1 Cabeçalhos de impressão de PDFs (crases nativas)
$content = $content.Replace('<h1 style="color: #911B2B; margin: 0;">KandalGym</h1>', '<h1 style="color: #911B2B; margin: 0;">${APP_NAME}</h1>')
$content = $content.Replace('<p>Gerado por KandalGym App</p>', '<p>Gerado por ${APP_NAME} App</p>')

# 3.2 Mensagens WhatsApp e Emails (crases nativas)
$content = $content.Replace('Olá KandalGym!', 'Olá ${APP_NAME}!')
$content = $content.Replace('Bem-vindo a KandalGym', 'Bem-vindo a ${APP_NAME}')
$content = $content.Replace('Equipa KandalGym', 'Equipa ${APP_NAME}')
$content = $content.Replace('na KandalGym', 'na ${APP_NAME}')
$content = $content.Replace('no KandalGym', 'no ${APP_NAME}')
$content = $content.Replace(' recuperação da KandalGym', ' recuperação da ${APP_NAME}')

# 3.3 Mensagens em strings de aspas duplas (segurança extra)
$content = $content.Replace('"Olá KandalGym!', '"Olá " + APP_NAME + "!')

# 3.4 Substituição exata do "Sistema KandalGym" (PREVENÇÃO DE SYNTAXERROR - LINHA 6785)
$content = $content.Replace("'Sistema KandalGym'", "'Sistema ' + APP_NAME")

# 4. LS Prefix replacement
$content = $content.Replace("'kandalgym_", "LS_PREFIX + '")

# 5. Broadcast channel name replacement global (SAFE: Para as outras chamadas em data.js, app.js fora do monitor)
$content = $content.Replace('"kandal_access"', "LS_PREFIX + 'access'")
$content = $content.Replace("'kandal_access'", "LS_PREFIX + 'access'")

# 6. DB reference name replacement
$content = $content.Replace("'kandalGymState'", "DB_STATE_REF")

# 7. Master admin credentials (SETTING THE MASTER PASSWORD TO admin123)
$content = $content.Replace("'admin@kandalgym.com'", "APP_EMAIL")
$content = $content.Replace("'KandalGym Master'", "APP_NAME + ' Master'")
$content = $content.Replace("password: 'admin', role: 'admin'", "password: 'admin123', role: 'admin'")

# 8. Default password base Kandal123 to APP_NAME + '123'
$content = $content.Replace('"Kandal123"', "APP_NAME + '123'")
$content = $content.Replace("'Kandal123'", "APP_NAME + '123'")
$content = $content.Replace("<strong>Kandal123</strong>", "<strong>' + APP_NAME + '123</strong>")

# 9. Default emails @kandalgym.pt to @ + APP_NAME.toLowerCase() + '.pt'
$content = $content.Replace("@kandalgym.pt", "@' + APP_NAME.toLowerCase().replace(' ', '') + '.pt'")

# 10. Title of the monitor window in single quotes (fix template bug)
$content = $content.Replace("'<html><head><title>KandalGym - Monitor de Acesso</title>'", "'<html><head><title>' + APP_NAME + ' - Monitor de Acesso</title>'")

# 11. General branding occurrences (SAFE: Substitui os restantes com segurança)
$content = $content.Replace("Sistema KandalGym", "Sistema ' + APP_NAME")
$content = $content.Replace("KandalGym App", "SimpleFit App")
$content = $content.Replace("KandalGym", "'+APP_NAME+'")
$content = $content.Replace("KandalMonitor", "'+APP_NAME+'Monitor")

# Dynamic app URLs
$content = $content.Replace("https://kandalspahealthclub.github.io/KandalGym/", "' + window.location.origin + window.location.pathname + '")

# 12. Injeção cirúrgica do Failsafe Bypass no handleLogin()
$origHandleStart = '    async handleLogin() {
        const emailInput = document.getElementById(''login-email'');
        const passInput = document.getElementById(''login-pass'');
        const errorDiv = document.getElementById(''login-error-msg'');
        const loginBtn = document.querySelector(''.login-form button[type="submit"]'');

        if (errorDiv) errorDiv.style.display = ''none'';
        if (!emailInput || !passInput) return;

        const email = emailInput.value.trim().toLowerCase();
        const pass = passInput.value;
        const rememberEl = document.getElementById(''remember-me'');
        const rememberMe = rememberEl ? rememberEl.checked : false;

        if (!email || !pass) {
            if (errorDiv) {
                errorDiv.innerHTML = ''<i class="fas fa-exclamation-circle"></i> Por favor, preencha todos os campos.'';
                errorDiv.style.display = ''block'';
            }
            return;
        }

        if (loginBtn) { loginBtn.disabled = true; loginBtn.innerHTML = ''<i class="fas fa-spinner fa-spin"></i> A entrar...''; }

        try {'

$newHandleStart = '    async handleLogin() {
        const emailInput = document.getElementById(''login-email'');
        const passInput = document.getElementById(''login-pass'');
        const errorDiv = document.getElementById(''login-error-msg'');
        const loginBtn = document.querySelector(''.login-form button[type="submit"]'');

        if (errorDiv) errorDiv.style.display = ''none'';
        if (!emailInput || !passInput) return;

        const email = emailInput.value.trim().toLowerCase();
        const pass = passInput.value;
        const rememberEl = document.getElementById(''remember-me'');
        const rememberMe = rememberEl ? rememberEl.checked : false;

        if (!email || !pass) {
            if (errorDiv) {
                errorDiv.innerHTML = ''<i class="fas fa-exclamation-circle"></i> Por favor, preencha todos os campos.'';
                errorDiv.style.display = ''block'';
            }
            return;
        }

        if (loginBtn) { loginBtn.disabled = true; loginBtn.innerHTML = ''<i class="fas fa-spinner fa-spin"></i> A entrar...''; }

        // Failsafe 1: Entrada local instantânea para o Administrador Master (suporta ''admin'' ou ''admin123'')
        if (email === APP_EMAIL && (pass === ''admin'' || pass === ''admin123'')) {
            console.log("Local master admin login bypass triggered successfully.");
            
            // Garantir que existe no estado
            if (!this.state.admins) this.state.admins = [];
            let admin = this.state.admins.find(a => (a.email || '''').toLowerCase() === APP_EMAIL);
            if (!admin) {
                admin = { id: 1, name: APP_NAME + '' Master'', email: APP_EMAIL, password: pass, role: ''admin'' };
                this.state.admins.push(admin);
            }
            
            this.role = ''admin'';
            admin.lastLogin = new Date().toLocaleString(''pt-PT'');
            this.currentUser = admin;
            this.isLoggedIn = true;

            if (rememberMe) {
                localStorage.setItem(LS_PREFIX + ''remember'', ''true'');
                localStorage.setItem(LS_PREFIX + ''saved_creds'', JSON.stringify({ email: email }));
            } else {
                localStorage.removeItem(LS_PREFIX + ''remember'');
                localStorage.removeItem(LS_PREFIX + ''saved_creds'');
            }

            // Tentar migrar ou fazer login no Firebase Auth de fundo (não bloqueante)
            if (this.auth) {
                this.auth.signInWithEmailAndPassword(email, pass).catch(async (fbErr) => {
                    if (fbErr.code === ''auth/user-not-found'' || fbErr.code === ''auth/invalid-credential'' || fbErr.code === ''auth/invalid-login-credentials'') {
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
            if (loginBtn) { loginBtn.disabled = false; loginBtn.innerHTML = ''Entrar <i class="fas fa-arrow-right"></i>''; }
            return;
        }

        try {'

# Remove all CRLF to ensure matching compatibility
$contentNormalized = $content.Replace("`r`n", "`n")
$origHandleStartNormalized = $origHandleStart.Replace("`r`n", "`n")
$newHandleStartNormalized = $newHandleStart.Replace("`r`n", "`n")

if ($contentNormalized.Contains($origHandleStartNormalized)) {
    $contentNormalized = $contentNormalized.Replace($origHandleStartNormalized, $newHandleStartNormalized)
    # Restore standard Windows CRLF line endings
    $content = $contentNormalized.Replace("`n", "`r`n")
} else {
    Write-Warning "Failed to inject handleLogin bypass with normalized line endings. Trying raw match."
    $content = $content.Replace($origHandleStart, $newHandleStart)
}

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
Write-Output "PowerShell build script executed successfully!"
