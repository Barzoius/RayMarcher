
#include "App.hpp"

#include <vector>

Application::Application()
{
    mWindow = std::make_unique<Window>(800, 600, "TOY_GFX");



    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "GLAD FAILED";
    }


    glEnable(GL_DEPTH_TEST);
}

Application::~Application()
{

}

void Application::OnEvent()
{
    if (glfwGetKey(mWindow->GetWindow(), GLFW_KEY_ESCAPE) == GLFW_PRESS)
    {
        glfwSetWindowShouldClose(mWindow->GetWindow(), true);
    }

    if (glfwGetKey(mWindow->GetWindow(), GLFW_KEY_P) == GLFW_PRESS)
    {
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    }

    if (glfwGetKey(mWindow->GetWindow(), GLFW_KEY_E) == GLFW_PRESS)
    {
        //glfwSetWindowShouldClose(mWindow->GetWindow(), true);
        std::cout << "E";
    }

}


void Application::Run()
{

    glm::mat4 cameraView;
    glm::mat4 projection = glm::mat4(1.0f);





    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);

    ShaderSuite ss = ShaderSuite(std::initializer_list<std::pair<std::string_view, Shader::ShaderType>>{
        {"Shader/BaseVertexShader.glsl", Shader::ShaderType::VERTEX},
        { "Shader/RayMarching.glsl", Shader::ShaderType::FRAGMENT },
        //{ "Shader/Compute1.glsl", Shader::ShaderType::COMPUTE }
    });
    
    GLuint ssbo;

    //glGenBuffers(1, &ssbo);
    //glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo);
    //glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(glm::vec3) * 8, NULL, GL_DYNAMIC_COPY); // 8 vertices
    //glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, ssbo);

    glm::vec2 res = glm::vec2(mWindow->GetWidth(), mWindow->GetHeight());


    while (!glfwWindowShouldClose(mWindow->GetWindow()))
    {

        mWindow->ProcessInput();

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


        projection = glm::perspective(glm::radians(45.0f), (float)mWindow->GetWidth() / (float)mWindow->GetHeight(), 0.1f, 100.0f);


        ss.setVec2("uResolution", res);
        ss.use();


        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);


        mWindow->OnUpdate();
    }

    glDeleteVertexArrays(1, &VAO);

}

bool Application::OnWindowClose()
{
    mIsRunning = false;
    return true;
}