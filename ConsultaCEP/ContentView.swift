//
//  ContentView.swift
//  ConsultaCEP
//
//  Created by Willian Santos on 3/11/23.
//

import SwiftUI

/* Result
 {
 "api": {
 "version": "beta",
 "rand": "1ca719923bf1016a0569614ceb66ebf3"
 },
 "return": {
 "name": "CEP",
 "source": "Vários",
 "cep": "07748-420",
 "logradouro": "Rua Kátia",
 "complemento": "(Sit Aparecida)",
 "bairro": "Vila Rosina",
 "localidade": "Caieiras",
 "uf": "SP",
 "codigo_ibge": "3509007",
 "codigo_uf_ibge": "35"
 }
 }
 */

struct Root: Decodable {
    let api: api
    let returns: returns
}

struct api: Codable {
    let version: String
    let rand: String
}

struct returns: Codable {
    var name: String
    var source: String
    var cep: String
    var logradouro: String
    var complemento: String
    var bairro: String
    var localidade: String
    var uf: String
    var codigo_ibge: String
    var codigo_uf_ibge: String
}

let token = "o0q6R6FtfHeFIyl-FrSMB3ThtZbyFlU_"

struct ContentView: View {
    @State var Cep: String = "07748420"
    @State var Api: api?
    @State var Endereco: returns?
    
    var body: some View {
        VStack {
            TextField("Digite o CEP", text: $Cep)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(UIKeyboardType.numberPad)
                .padding()
            
            Button("Consultar") {
                consultarCep()
            }
            .padding()
            
            
            if let api = Api {
                VStack(alignment: .leading) {
                    Text("Versão da API: \(api.version)")
                    Text("ID da Requisição: \(api.rand)")
                }
                .padding()
            }
            
            if let endereco = Endereco {
                VStack(alignment: .leading) {
                    Text("Nome da API: \(endereco.name)")
                    Text("Fonte da API: \(endereco.source)")
                    Text("CEP: \(endereco.cep)")
                    Text("Logradouro: \(endereco.logradouro)")
                    Text("Complemento: \(endereco.complemento)")
                    Text("Bairro: \(endereco.bairro)")
                    Text("Cidade: \(endereco.localidade)")
                    Text("Estado: \(endereco.uf)")
                    Text("IBGE: \(endereco.codigo_ibge)")
                    Text("IBGE/UF: \(endereco.codigo_uf_ibge)")
                }
                .padding()
            }
            
        }
    }
    
    func consultarCep() {
        guard let url = URL(string: "http://brasilapi.simplescontrole.com.br/correios/consulta-cep?cep=\(Cep)&_format=json&access-token=\(token)") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str!)
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        //self.Api = try decoder.decode(api.self, from: data)
                        let CepResponse = try decoder.decode(returns.self, from: data)
                        self.Endereco = CepResponse
                    }
                    catch {
                        print(error)
                    }
                }
                /*
                 let decoder = JSONDecoder()
                 if let decodedResponse = try? decoder.decode(Root.self, from: data) {
                 DispatchQueue.main.async {
                 self.api = decodedResponse.API
                 self.endereco = decodedResponse.CEP
                 }
                 } else {
                 print("Erro ao decodificar resposta JSON")
                 }
                 */
            } else if let error = error {
                print("Erro na requisição: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
