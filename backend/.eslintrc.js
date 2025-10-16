module.exports = {
  env: {
    node: true,
    es2021: true
  },
  extends: [
    'standard'
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module'
  },
  rules: {
    // Regras de espaçamento
    indent: ['error', 2], // Indentação de 2 espaços
    'space-before-function-paren': ['error', 'never'], // Sem espaço antes de parênteses de função
    'space-infix-ops': 'error', // Espaços ao redor de operadores infixos
    'space-before-blocks': 'error', // Espaço antes de blocos
    'keyword-spacing': 'error', // Espaços ao redor de palavras-chave
    'comma-spacing': ['error', { before: false, after: true }], // Espaço após vírgulas, não antes
    'object-curly-spacing': ['error', 'always'], // Espaços dentro de chaves de objetos
    'array-bracket-spacing': ['error', 'never'], // Sem espaços dentro de colchetes de arrays
    'key-spacing': ['error', { beforeColon: false, afterColon: true }], // Sem espaço antes de :, espaço após
    'semi-spacing': ['error', { before: false, after: true }], // Sem espaço antes de ;, espaço após

    // Outras regras úteis
    'no-unused-vars': 'warn', // Avisar sobre variáveis não usadas
    semi: ['error', 'always'], // Ponto e vírgula obrigatório
    quotes: ['error', 'single'], // Aspas simples obrigatórias
    'no-console': 'off', // Permitir console.log (útil em desenvolvimento)
    'no-trailing-spaces': 'error', // Sem espaços no final das linhas
    'eol-last': 'error', // Nova linha no final do arquivo
    'no-multiple-empty-lines': ['error', { max: 1 }], // Máximo 1 linha vazia consecutiva
    'comma-dangle': ['error', 'never'], // Sem vírgula no final de objetos/arrays
    'brace-style': ['error', '1tbs'], // Estilo de chaves (1tbs)
    'func-call-spacing': ['error', 'never'], // Sem espaço entre nome da função e parênteses
    'no-var': 'error', // Usar let/const ao invés de var
    'prefer-const': 'error' // Usar const quando possível
  }
};
