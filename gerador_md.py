import os
import shutil

def recursivo_para_md(pasta_alvo, pasta_saida_base="arquivos_md"):
    try:
        caminho_completo_saida_base = os.path.join(os.path.dirname(pasta_alvo.rstrip(os.sep)), pasta_saida_base)

        if not os.path.exists(caminho_completo_saida_base):
            os.makedirs(caminho_completo_saida_base)
            print(f"Pasta de saída base criada em: {caminho_completo_saida_base}")

        for diretorio_atual, subpastas, arquivos in os.walk(pasta_alvo):
            caminho_relativo = os.path.relpath(diretorio_atual, pasta_alvo)
            diretorio_saida_atual = os.path.join(caminho_completo_saida_base, caminho_relativo)

            if not os.path.exists(diretorio_saida_atual):
                os.makedirs(diretorio_saida_atual)
                
            for nome_arquivo in arquivos:
                caminho_arquivo_original = os.path.join(diretorio_atual, nome_arquivo)
                
                novo_nome_md = nome_arquivo + ".md"
                caminho_novo_arquivo_md = os.path.join(diretorio_saida_atual, novo_nome_md)

                shutil.copy2(caminho_arquivo_original, caminho_novo_arquivo_md)
                
                print(f"Copiado e renomeado para: {caminho_novo_arquivo_md}")
        
        print(f"\nProcesso concluído! Estrutura de arquivos .md com conteúdo criada em '{caminho_completo_saida_base}'.")

    except FileNotFoundError:
        print(f"Erro: A pasta alvo '{pasta_alvo}' não foi encontrada.")
    except Exception as e:
        print(f"Ocorreu um erro inesperado: {e}")

if __name__ == "__main__":
    # r"C:\Users\SeuUsuario\Documentos\ArduPilot" > Windows
    # pasta_raiz_ardupilot = "/home/seuusuario/Documentos/ArduPilot" > Linux
    
    pasta_raiz_ardupilot = r"D:\D\ardupilot-master\ardupilot-master\Rover" # >>

    if os.path.isdir(pasta_raiz_ardupilot):
        nome_pasta_saida = os.path.basename(pasta_raiz_ardupilot.rstrip(os.sep)) + "_arquivos_md"
        recursivo_para_md(pasta_raiz_ardupilot, pasta_saida_base=nome_pasta_saida)
    else:
        print(f"O caminho fornecido '{pasta_raiz_ardupilot}' não é um diretório válido.")