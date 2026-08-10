import SwiftUI
import PhotosUI

struct ModuleView:View {
    @EnvironmentObject var data:SolarData
    let module:PVModule
    @State private var inspect=false
    var current:PVModule { data.modules.first{$0.id==module.id} ?? module }
    var body:some View {
        List {
            Section { Text(current.id).font(.title.bold()); Text("\(current.block) • \(current.table) • \(current.string) • \(current.position)") }
            Section("Estado"){Text(current.state.rawValue).foregroundStyle(current.state.color)}
            Section("Localização"){
                LabeledContent("Latitude",value:String(format:"%.6f",current.latitude))
                LabeledContent("Longitude",value:String(format:"%.6f",current.longitude))
            }
            Section("Ações"){
                Button("Nova inspeção"){inspect=true}
                NavigationLink("Abrir ordem de serviço",destination:Text("Vincular OS a \(current.id)"))
                NavigationLink("QR Code do módulo",destination:QRCodeView(code:current.id))
            }
            Section("Histórico"){
                if current.inspections.isEmpty {Text("Nenhuma inspeção registrada.").foregroundStyle(.secondary)}
                ForEach(current.inspections){i in VStack(alignment:.leading){Text("\(i.type) • \(i.defect)").bold();Text(i.date.formatted());Text(i.notes)}}
            }
        }.navigationTitle("Módulo").sheet(isPresented:$inspect){InspectionView(module:current)}
    }
}
struct InspectionView:View {
    @EnvironmentObject var data:SolarData
    @Environment(\.dismiss) var dismiss
    let module:PVModule
    @State private var type="Visual"
    @State private var defect="Sem defeito"
    @State private var severity="Normal"
    @State private var inspector=""
    @State private var notes=""
    @State private var photo:PhotosPickerItem?
    let defects=["Sem defeito","Módulo quebrado","Vidro trincado","Microtrinca","Hotspot","Delaminação","Sujidade","Cabo danificado","Conector danificado","Baixa geração","Outro"]
    var body:some View {
        NavigationStack{Form{
            Picker("Inspeção",selection:$type){ForEach(["Visual","Termografia","Drone","Elétrica"],id:\.self){Text($0)}}
            Picker("Defeito",selection:$defect){ForEach(defects,id:\.self){Text($0)}}
            Picker("Gravidade",selection:$severity){ForEach(["Normal","Baixa","Média","Alta","Crítica"],id:\.self){Text($0)}}
            TextField("Inspetor",text:$inspector)
            TextEditor(text:$notes).frame(height:100)
            PhotosPicker(selection:$photo,matching:.images){Label("Adicionar evidência",systemImage:"camera.fill")}
            Button("Salvar inspeção"){save()}
        }.navigationTitle("Nova inspeção")}
    }
    func save(){
        guard let idx=data.modules.firstIndex(where:{$0.id==module.id}) else{return}
        let st:ModuleState = severity=="Crítica" ? .critical : severity=="Alta" ? .medium : severity=="Normal" ? .normal : .light
        data.modules[idx].state=st
        data.modules[idx].inspections.append(.init(type:type,defect:defect,severity:severity,inspector:inspector,notes:notes,latitude:module.latitude,longitude:module.longitude))
        dismiss()
    }
}
