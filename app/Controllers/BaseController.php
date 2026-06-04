<?php
/**
 * CEAMS - Base Controller Class
 * Parent class for all controllers
 */

namespace App\Controllers;

use Core\Request;
use Core\Response;

class BaseController
{
    protected $request;
    protected $response;
    protected $view;
    protected $auth = null;
    protected $currentUser = null;

    public function __construct()
    {
        $this->request = Request::class;
        $this->response = Response::class;
        $this->checkAuth();
    }

    /**
     * Check user authentication
     */
    protected function checkAuth()
    {
        if (isset($_SESSION['user_id'])) {
            $userModel = new \App\Models\User();
            $this->currentUser = $userModel->find($_SESSION['user_id']);
            $this->auth = $this->currentUser;
        }
    }

    /**
     * Render view
     */
    protected function view($name, $data = [])
    {
        extract($data);
        $viewPath = __DIR__ . '/../../resources/views/' . str_replace('.', '/', $name) . '.php';

        if (!file_exists($viewPath)) {
            die("View not found: $viewPath");
        }

        include $viewPath;
    }

    /**
     * Require authentication
     */
    protected function requireAuth()
    {
        if (!$this->auth) {
            Response::flash('Please login first', 'error');
            Response::redirect('/login');
        }
    }

    /**
     * Require specific role
     */
    protected function requireRole($role)
    {
        $this->requireAuth();
        // Check role - implementation depends on your role system
    }

    /**
     * Return JSON response
     */
    protected function json($data, $statusCode = 200)
    {
        Response::json($data, $statusCode);
    }

    /**
     * Redirect
     */
    protected function redirect($url)
    {
        Response::redirect($url);
    }
}
