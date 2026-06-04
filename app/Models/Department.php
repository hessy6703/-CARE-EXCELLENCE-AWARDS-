<?php
/**
 * CEAMS - Department Model
 */

namespace App\Models;

class Department extends BaseModel
{
    protected $table = 'departments';
    protected $fillable = ['name', 'code', 'description', 'status'];

    /**
     * Get department by code
     */
    public function findByCode($code)
    {
        return $this->findBy('code', $code);
    }

    /**
     * Get active departments
     */
    public function getActive()
    {
        $sql = "SELECT * FROM {$this->table} WHERE status = 'active' ORDER BY name ASC";
        $this->db->query($sql);
        return $this->db->resultSet();
    }

    /**
     * Get department with supervisor
     */
    public function getDepartmentWithSupervisor($departmentId)
    {
        $sql = "SELECT d.*, u.first_name, u.last_name, u.email 
                FROM {$this->table} d
                LEFT JOIN department_supervisors ds ON d.id = ds.department_id
                LEFT JOIN users u ON u.id = ds.supervisor_id
                WHERE d.id = :id";
        $this->db->query($sql);
        $this->db->bind(':id', $departmentId);
        return $this->db->single();
    }
}
