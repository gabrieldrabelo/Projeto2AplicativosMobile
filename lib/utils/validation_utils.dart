class ValidationUtils {
  // Validau00e7u00e3o de e-mail
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }
  
  // Validau00e7u00e3o de CPF
  static bool isValidCPF(String cpf) {
    // Remove caracteres nu00e3o numu00e9ricos
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 11 du00edgitos
    if (cpf.length != 11) {
      return false;
    }
    
    // Verifica se todos os du00edgitos su00e3o iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }
    
    // Calcula o primeiro du00edgito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 > 9) digito1 = 0;
    
    // Calcula o segundo du00edgito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 > 9) digito2 = 0;
    
    // Verifica se os du00edgitos calculados su00e3o iguais aos du00edgitos informados
    return (digito1 == int.parse(cpf[9]) && digito2 == int.parse(cpf[10]));
  }
  
  // Validau00e7u00e3o de CNPJ
  static bool isValidCNPJ(String cnpj) {
    // Remove caracteres nu00e3o numu00e9ricos
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 14 du00edgitos
    if (cnpj.length != 14) {
      return false;
    }
    
    // Verifica se todos os du00edgitos su00e3o iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) {
      return false;
    }
    
    // Calcula o primeiro du00edgito verificador
    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 > 9) digito1 = 0;
    
    // Calcula o segundo du00edgito verificador
    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 > 9) digito2 = 0;
    
    // Verifica se os du00edgitos calculados su00e3o iguais aos du00edgitos informados
    return (digito1 == int.parse(cnpj[12]) && digito2 == int.parse(cnpj[13]));
  }
  
  // Validau00e7u00e3o de telefone
  static bool isValidPhone(String phone) {
    // Remove caracteres nu00e3o numu00e9ricos
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 10 ou 11 du00edgitos (com ou sem o 9)
    return phone.length >= 10 && phone.length <= 11;
  }
  
  // Validau00e7u00e3o de CEP
  static bool isValidCEP(String cep) {
    // Remove caracteres nu00e3o numu00e9ricos
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 8 du00edgitos
    return cep.length == 8;
  }
  
  // Validação de URL
  static bool isValidURL(String url) {
    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([\-a-zA-Z0-9._~:/?#\[\]@!  // Validau00e7u00e3o de URL
  static bool isValidURL(String url) {
    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-a-zA-Z0-9._~:/?#[\]@!$&'()*+,;=]*)?$',
    );
    return urlRegExp.hasMatch(url);
  }\(\)*+,;=]*)?
  
  // Validau00e7u00e3o de senha forte
  static bool isStrongPassword(String password) {
    // Pelo menos 8 caracteres, uma letra maiu00fascula, uma minu00fascula, um nu00famero e um caractere especial
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }
},
    );
    return urlRegExp.hasMatch(url);
  }
  
  // Validau00e7u00e3o de senha forte
  static bool isStrongPassword(String password) {
    // Pelo menos 8 caracteres, uma letra maiu00fascula, uma minu00fascula, um nu00famero e um caractere especial
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }
}